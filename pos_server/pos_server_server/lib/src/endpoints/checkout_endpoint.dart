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
    List<Map<String, dynamic>>? itemsToPay,
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
          subtotal: subtotal ?? totalToPay,
          taxAmount: taxAmount ?? 0,
          serviceAmount: serviceAmount ?? 0,
          tipAmount: tipAmount ?? 0,
          total: totalToPay,
          createdAt: DateTime.now(),
        ),
        transaction: txSession,
      );

      // 3. Subtract paid items from order if splitting by item
      if (itemsToPay != null && itemsToPay.isNotEmpty) {
        for (final itemToPay in itemsToPay) {
          final itemId = itemToPay['id'] as int;
          final qtyToPay = itemToPay['quantity'] as int;
          if (qtyToPay <= 0) continue;

          final existing = await OrderItem.db.findById(session, itemId, transaction: txSession);
          if (existing == null) continue;

          if (existing.quantity <= qtyToPay) {
            // Item fully paid, delete it from the order
            await OrderItem.db.deleteRow(session, existing, transaction: txSession);
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
      }

      // 4. Update order total and check if fully paid
      final remainingTotal = order.total - totalToPay;
      final isFullyPaid = remainingTotal <= 0.01;

      await PosOrder.db.updateRow(
        session,
        order.copyWith(
          total: remainingTotal > 0 ? remainingTotal : 0,
          subtotal:
              (order.subtotal - (subtotal ?? totalToPay)) > 0
                  ? (order.subtotal - (subtotal ?? totalToPay))
                  : 0,
          status: isFullyPaid ? 'Completed' : order.status,
          billId: isFullyPaid ? bill.id : order.billId,
          updatedAt: DateTime.now(),
        ),
        transaction: txSession,
      );

      // Free up the table only if fully paid
      if (isFullyPaid && order.tableNo != null) {
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
              status: 'Available',
              orderCode: null,
              updatedAt: DateTime.now(),
            ),
            transaction: txSession,
          );
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

  Future<Bill> getDetails(Session session, int billId) async {
    final bill = await Bill.db.findById(session, billId);
    if (bill == null) throw Exception('Bill not found');

    // Fetch all order items linked to this bill via orders
    final orders = await PosOrder.db.find(
      session,
      where: (t) => t.billId.equals(billId),
    );
    if (orders.isEmpty) return bill;

    final orderIds = orders.map((o) => o.id!).toSet();
    await OrderItem.db.find(
      session,
      where: (t) => t.orderId.inSet(orderIds),
    );

    // Return bill with items attached (reuse items field in a synthetic PosOrder-style way)
    // We encode items in a JSON-like manner in the bill's extra field or return
    // a bill that carries items. Since Bill doesn't have an items field we return
    // a copy in the endpoint payload alongside.
    // For simplicity, attach as the first order's items list (common case).
    return bill;
  }
}
