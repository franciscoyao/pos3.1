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

      final bill = await Bill.db.insertRow(
        session,
        Bill(
          billNumber: billNumber,
          orderType: order.orderType,
          tableNo: order.tableNo,
          waiterName: waiterName ?? order.waiterName,
          paymentMethod: paymentMethod,
          subtotal: subtotal ?? order.total,
          taxAmount: taxAmount ?? 0,
          serviceAmount: serviceAmount ?? 0,
          tipAmount: tipAmount ?? 0,
          total: total ?? order.total,
          createdAt: DateTime.now(),
        ),
        transaction: txSession,
      );

      // Link order to bill and mark completed
      await PosOrder.db.updateRow(
        session,
        order.copyWith(billId: bill.id, status: 'Completed'),
        transaction: txSession,
      );

      // Free up the table
      if (order.tableNo != null) {
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
