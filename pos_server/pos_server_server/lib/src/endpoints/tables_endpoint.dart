import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../event_service.dart';

class TablesEndpoint extends Endpoint {
  Future<List<RestaurantTable>> getAll(Session session) async {
    return await RestaurantTable.db.find(
      session,
      orderBy: (t) => t.tableNumber,
    );
  }

  Future<RestaurantTable> create(Session session, String tableNumber) async {
    final table = RestaurantTable(
      tableNumber: tableNumber,
      status: 'Available',
      guestCount: 0,
      updatedAt: DateTime.now(),
    );
    final result = await RestaurantTable.db.insertRow(session, table);
    await EventService.broadcast(session, 'table_updated');
    return result;
  }

  Future<RestaurantTable> update(
    Session session,
    int id,
    String status,
    String? orderCode,
    int guestCount,
  ) async {
    final existing = await RestaurantTable.db.findById(session, id);
    if (existing == null) throw Exception('Table not found');
    final updated = existing.copyWith(
      status: status,
      orderCode: orderCode,
      guestCount: guestCount,
      updatedAt: DateTime.now(),
    );
    final result = await RestaurantTable.db.updateRow(session, updated);
    await EventService.broadcast(session, 'table_updated');
    return result;
  }

  Future<bool> delete(Session session, int id) async {
    final table = await RestaurantTable.db.findById(session, id);
    if (table == null) return false;
    await RestaurantTable.db.deleteRow(session, table);
    await EventService.broadcast(session, 'table_updated');
    return true;
  }

  Future<void> mergeTables(
    Session session,
    String sourceTableNumber,
    String targetTableNumber,
  ) async {
    await session.db.transaction((transaction) async {
      // 1. Find all active orders for the source table
      final sourceOrders = await PosOrder.db.find(
        session,
        where: (t) =>
            t.tableNo.equals(sourceTableNumber) &
            t.status.notEquals('Completed') &
            t.status.notEquals('Cancelled'),
        transaction: transaction,
      );

      if (sourceOrders.isEmpty) return;

      // 2. Find or create target order
      var targetOrder = await PosOrder.db.findFirstRow(
        session,
        where: (t) =>
            t.tableNo.equals(targetTableNumber) &
            t.status.notEquals('Completed') &
            t.status.notEquals('Cancelled'),
        transaction: transaction,
      );

      if (targetOrder == null) {
        final firstSource = sourceOrders.first;
        targetOrder = await PosOrder.db.insertRow(
          session,
          PosOrder(
            tableNo: targetTableNumber,
            status: 'Pending',
            orderType: firstSource.orderType,
            waiterName: firstSource.waiterName,
            total: 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            orderCode: 'ORD-M-${DateTime.now().millisecondsSinceEpoch}',
          ),
          transaction: transaction,
        );
      }

      // 3. Move all items from all source orders to target order
      for (final sOrder in sourceOrders) {
        final items = await OrderItem.db.find(
          session,
          where: (t) => t.orderId.equals(sOrder.id!),
          transaction: transaction,
        );

        for (final item in items) {
          await OrderItem.db.updateRow(
            session,
            item.copyWith(orderId: targetOrder!.id!),
            transaction: transaction,
          );
        }

        // Update target order total
        targetOrder = targetOrder!.copyWith(
          total: targetOrder.total + sOrder.total,
          updatedAt: DateTime.now(),
        );

        // Delete source order
        await PosOrder.db.deleteRow(session, sOrder, transaction: transaction);
      }

      // Save target order final total
      await PosOrder.db.updateRow(
        session,
        targetOrder!,
        transaction: transaction,
      );

      // 4. Update source table status if it exists
      final sourceTable = await RestaurantTable.db.findFirstRow(
        session,
        where: (t) => t.tableNumber.equals(sourceTableNumber),
        transaction: transaction,
      );
      if (sourceTable != null) {
        await RestaurantTable.db.updateRow(
          session,
          sourceTable.copyWith(status: 'Available', updatedAt: DateTime.now()),
          transaction: transaction,
        );
      }

      // 5. Ensure target table status is Occupied
      final targetTable = await RestaurantTable.db.findFirstRow(
        session,
        where: (t) => t.tableNumber.equals(targetTableNumber),
        transaction: transaction,
      );
      if (targetTable != null) {
        await RestaurantTable.db.updateRow(
          session,
          targetTable.copyWith(status: 'Occupied', updatedAt: DateTime.now()),
          transaction: transaction,
        );
      }
    });

    await EventService.broadcast(session, 'table_updated');
    await EventService.broadcast(session, 'order_updated');
  }

  /// Tags selected items with a billingTableNo for split billing.
  /// The original kitchen order is NEVER modified — items stay in their
  /// original PosOrder so the kitchen sees no changes. Only the billing
  /// grouping is updated.
  Future<bool> moveItemsToTable(
    Session session,
    List<int> itemIds,
    List<int> quantities,
    String targetTableNo,
  ) async {
    return await session.db.transaction<bool>((txSession) async {

      for (int i = 0; i < itemIds.length; i++) {
        final itemId = itemIds[i];
        final qtyToMove = quantities[i];

        final existing = await OrderItem.db.findById(
          session,
          itemId,
          transaction: txSession,
        );
        if (existing == null) continue;

        if (existing.quantity <= qtyToMove) {
          // Tag the entire item to the billing table
          await OrderItem.db.updateRow(
            session,
            existing.copyWith(billingTableNo: targetTableNo),
            transaction: txSession,
          );
        } else {
          // Partially tag: shrink the original item's quantity,
          // create a new sibling item (same orderId!) tagged to the billing table
          final pricePerUnit = existing.price;
          final remainingQty = existing.quantity - qtyToMove;

          // Shrink original
          await OrderItem.db.updateRow(
            session,
            existing.copyWith(
              quantity: remainingQty,
              totalPrice: remainingQty * pricePerUnit,
            ),
            transaction: txSession,
          );

          // Create sibling tagged for billing table — same orderId, kitchen is unaffected
          await OrderItem.db.insertRow(
            session,
            OrderItem(
              orderId: existing.orderId,
              productId: existing.productId,
              productName: existing.productName,
              productStation: existing.productStation,
              quantity: qtyToMove,
              price: pricePerUnit,
              totalPrice: qtyToMove * pricePerUnit,
              notes: existing.notes,
              extras: existing.extras,
              billingTableNo: targetTableNo,
            ),
            transaction: txSession,
          );
        }
      }

      // Broadcast table_updated so the waiter's tablet refreshes.
      // No order_created is broadcast, so the kitchen will NOT print a new KOT.
      await EventService.broadcast(session, 'table_updated');
      await EventService.broadcast(session, 'order_updated');
      return true;
    });
  }
}
