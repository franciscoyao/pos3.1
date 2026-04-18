import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../event_service.dart';

class CheckoutEndpoint extends Endpoint {
  Future<Bill> checkout(
    Session session,
    int orderId,
    String paymentMethod, {
    String? waiterName,
    double? subtotal,
    double? taxAmount,
    double? serviceAmount,
    double? tipAmount,
    double? total,
    String? taxNumber,
    int? initialSplitCount,
    int? remainingSplitCount,
    List<CheckoutItem>? itemsToPay,
  }) async {
    return await session.db.transaction<Bill>((txSession) async {
      final order = await PosOrder.db.findById(
        session,
        orderId,
        transaction: txSession,
      );
      if (order == null) throw Exception('Order not found');

      // Prevent double checkouts
      if (order.status == 'Completed' || order.billId != null) {
        throw Exception('Order is already checked out.');
      }

      final billNumber = 'BILL-${DateTime.now().millisecondsSinceEpoch}';
      final totalToPay = total ?? order.total;

      final bill = await Bill.db.insertRow(
        session,
        Bill(
          billNumber: billNumber,
          orderType: order.orderType,
          tableNo: order.tableNo,
          waiterName: waiterName ?? order.waiterName,
          paymentMethod: paymentMethod,
          taxNumber: taxNumber,
          subtotal: subtotal ?? totalToPay,
          taxAmount: taxAmount ?? 0,
          serviceAmount: serviceAmount ?? 0,
          tipAmount: tipAmount ?? 0,
          total: totalToPay,
          createdAt: DateTime.now(),
        ),
        transaction: txSession,
      );

      // 3. Save Bill Items and Subtract from order if needed
      if (itemsToPay != null && itemsToPay.isNotEmpty) {
        for (final itemToPay in itemsToPay) {
          final itemId = itemToPay.id;
          final qtyToPay = itemToPay.quantity;
          if (qtyToPay <= 0) continue;

          final existing = await OrderItem.db.findById(
            session,
            itemId,
            transaction: txSession,
          );
          if (existing == null) continue;

          // Save to BillItem
          await BillItem.db.insertRow(
            session,
            BillItem(
              billId: bill.id!,
              productName: existing.productName,
              quantity: qtyToPay,
              price: existing.price,
              totalPrice: qtyToPay * existing.price,
            ),
            transaction: txSession,
          );

          if (existing.quantity <= qtyToPay) {
            // Item fully paid, delete it from the order
            await OrderItem.db.deleteRow(
              session,
              existing,
              transaction: txSession,
            );
          } else {
            // Item partially paid, reduce quantity
            final remainingQty = existing.quantity - qtyToPay;
            await OrderItem.db.updateRow(
              session,
              existing.copyWith(
                quantity: remainingQty,
                totalPrice: remainingQty * existing.price,
              ),
              transaction: txSession,
            );
          }
        }
      } else {
        // No itemsToPay provided. If it's a full payment, record all items in the Bill
        final remainingTotal = order.total - totalToPay;
        final isFullyPaid = remainingTotal <= 0.01;

        if (isFullyPaid) {
          final items = await OrderItem.db.find(
            session,
            where: (t) => t.orderId.equals(order.id!),
            transaction: txSession,
          );
          for (final item in items) {
            await BillItem.db.insertRow(
              session,
              BillItem(
                billId: bill.id!,
                productName: item.productName,
                quantity: item.quantity,
                price: item.price,
                totalPrice: item.totalPrice,
              ),
              transaction: txSession,
            );
            // Delete item from active order
            await OrderItem.db.deleteRow(
              session,
              item,
              transaction: txSession,
            );
          }
        }
      }

      // 4. Update order total and check if fully paid
      final remainingTotal = order.total - totalToPay;

      // If we are splitting by seat/people, we check the remaining count
      bool isFullyPaid;
      if (remainingSplitCount != null) {
        isFullyPaid = remainingSplitCount <= 0;
      } else {
        isFullyPaid = remainingTotal <= 0.01;
      }

      await PosOrder.db.updateRow(
        session,
        order.copyWith(
          total: remainingTotal > 0 ? remainingTotal : 0,
          subtotal: (order.subtotal - (subtotal ?? totalToPay)) > 0
              ? (order.subtotal - (subtotal ?? totalToPay))
              : 0,
          status: isFullyPaid ? 'Completed' : order.status,
          billId: isFullyPaid ? bill.id : order.billId,
          initialSplitCount: initialSplitCount ?? order.initialSplitCount,
          remainingSplitCount: remainingSplitCount,
          updatedAt: DateTime.now(),
        ),
        transaction: txSession,
      );

      // Only update table if this order is fully paid
      if (isFullyPaid && order.tableNo != null) {
        // Check if there are ANY other active orders for this table
        final otherActiveOrders = await PosOrder.db.find(
          session,
          where: (t) =>
              t.tableNo.equals(order.tableNo!) &
              t.id.notEquals(order.id!) &
              t.status.notEquals('Completed') &
              t.status.notEquals('Cancelled'),
          transaction: txSession,
        );

        if (otherActiveOrders.isEmpty) {
          // No other active orders, we can safely delete the table record (make it vacant)
          final tables = await RestaurantTable.db.find(
            session,
            where: (t) => t.tableNumber.equals(order.tableNo!),
            limit: 1,
            transaction: txSession,
          );
          if (tables.isNotEmpty) {
            await RestaurantTable.db.deleteRow(
              session,
              tables.first,
              transaction: txSession,
            );
          }
        } else {
          // There are other active orders, keep the table occupied.
          // Optionally update the table's orderCode to one of the other active orders.
          final tables = await RestaurantTable.db.find(
            session,
            where: (t) => t.tableNumber.equals(order.tableNo!),
            limit: 1,
            transaction: txSession,
          );
          if (tables.isNotEmpty) {
            await RestaurantTable.db.updateRow(
              session,
              tables.first.copyWith(
                orderCode: otherActiveOrders.first.orderCode,
                updatedAt: DateTime.now(),
              ),
              transaction: txSession,
            );
          }
        }
      }

      await EventService.broadcast(session, 'checkout_completed');
      await EventService.broadcast(session, 'table_updated');
      await EventService.broadcast(session, 'order_updated');

      return bill;
    });
  }

  Future<List<Bill>> getAll(Session session) async {
    return await Bill.db.find(
      session,
      orderBy: (t) => t.createdAt,
      orderDescending: true,
    );
  }

  Future<BillWithItems> getDetails(Session session, int billId) async {
    final bill = await Bill.db.findById(session, billId);
    if (bill == null) throw Exception('Bill not found');

    final items = await BillItem.db.find(
      session,
      where: (t) => t.billId.equals(billId),
    );

    return BillWithItems(
      bill: bill,
      items: items,
    );
  }
}
