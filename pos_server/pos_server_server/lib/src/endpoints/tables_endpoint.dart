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
            t.status.inSet({'Pending', 'In Progress'}),
        transaction: transaction,
      );

      if (sourceOrders.isEmpty) return;

      // 2. Find or create target order
      var targetOrder = await PosOrder.db.findFirstRow(
        session,
        where: (t) =>
            t.tableNo.equals(targetTableNumber) &
            t.status.inSet({'Pending', 'In Progress'}),
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

  Future<bool> moveItemsToTable(
    Session session,
    List<int> itemIds,
    List<int> quantities,
    String targetTableNo,
  ) async {
    return await session.db.transaction<bool>((txSession) async {
      final now = DateTime.now();

      // 1. Find or create target table
      final targetTables = await RestaurantTable.db.find(
        session,
        where: (t) => t.tableNumber.equals(targetTableNo),
        limit: 1,
        transaction: txSession,
      );

      RestaurantTable targetTable;
      String orderCode;

      if (targetTables.isNotEmpty && targetTables.first.status == 'Occupied') {
        targetTable = targetTables.first;
        orderCode = targetTable.orderCode!;
      } else {
        orderCode = 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
        if (targetTables.isNotEmpty) {
          targetTable = await RestaurantTable.db.updateRow(
            session,
            targetTables.first.copyWith(
              status: 'Occupied',
              orderCode: orderCode,
              updatedAt: now,
            ),
            transaction: txSession,
          );
        } else {
          targetTable = await RestaurantTable.db.insertRow(
            session,
            RestaurantTable(
              tableNumber: targetTableNo,
              status: 'Occupied',
              orderCode: orderCode,
              updatedAt: now,
              guestCount: 0,
            ),
            transaction: txSession,
          );
        }
      }

      // 2. Find or create the active order for the target table
      final activeOrders = await PosOrder.db.find(
        session,
        where: (t) => t.orderCode.equals(orderCode) & t.status.notEquals('Completed') & t.status.notEquals('Cancelled'),
        limit: 1,
        transaction: txSession,
      );

      PosOrder targetOrder;
      if (activeOrders.isNotEmpty) {
        targetOrder = activeOrders.first;
      } else {
        targetOrder = await PosOrder.db.insertRow(
          session,
          PosOrder(
            orderCode: orderCode,
            orderType: 'Dine-In',
            tableNo: targetTableNo,
            status: 'Pending',
            total: 0,
            subtotal: 0,
            createdAt: now,
            updatedAt: now,
          ),
          transaction: txSession,
        );
      }

      // 3. Move items and update totals
      double totalMoved = 0;
      for (int i = 0; i < itemIds.length; i++) {
        final itemId = itemIds[i];
        final qtyToMove = quantities[i];

        final existing = await OrderItem.db.findById(session, itemId, transaction: txSession);
        if (existing == null) continue;

        if (existing.quantity <= qtyToMove) {
          // Move full item
          totalMoved += existing.totalPrice;
          await OrderItem.db.updateRow(
            session,
            existing.copyWith(orderId: targetOrder.id!),
            transaction: txSession,
          );
        } else {
          // Split item quantity
          final pricePerUnit = existing.price;
          final movedPrice = pricePerUnit * qtyToMove;
          totalMoved += movedPrice;

          // Update source item
          final remainingQty = existing.quantity - qtyToMove;
          await OrderItem.db.updateRow(
            session,
            existing.copyWith(
              quantity: remainingQty,
              totalPrice: remainingQty * pricePerUnit,
            ),
            transaction: txSession,
          );

          // Create new item in target order
          await OrderItem.db.insertRow(
            session,
            OrderItem(
              orderId: targetOrder.id!,
              productId: existing.productId,
              productName: existing.productName,
              productStation: existing.productStation,
              quantity: qtyToMove,
              price: pricePerUnit,
              totalPrice: movedPrice,
              notes: existing.notes,
              extras: existing.extras,
            ),
            transaction: txSession,
          );
        }
      }

      // 4. Update order totals
      // Update target
      await PosOrder.db.updateRow(
        session,
        targetOrder.copyWith(
          total: targetOrder.total + totalMoved,
          subtotal: targetOrder.subtotal + totalMoved,
          updatedAt: now,
        ),
        transaction: txSession,
      );

      // Update source(s) - for simplicity, we find the orders affected
      final sourceOrderIds = (await OrderItem.db.find(session, where: (t) => t.id.inSet(itemIds.toSet()))).map((e) => e.orderId).toSet();
      // Actually we already have the source items, but they might belong to different orders if a table has multiple.
      // Re-calculating all affected source orders is safer.
      for (final sId in sourceOrderIds) {
        final sOrder = await PosOrder.db.findById(session, sId, transaction: txSession);
        if (sOrder == null) continue;
        
        final sItems = await OrderItem.db.find(session, where: (t) => t.orderId.equals(sId), transaction: txSession);
        final newTotal = sItems.fold(0.0, (sum, item) => sum + item.totalPrice);
        
        await PosOrder.db.updateRow(
          session,
          sOrder.copyWith(
            total: newTotal,
            subtotal: newTotal,
            updatedAt: now,
          ),
          transaction: txSession,
        );
      }

      await EventService.broadcast(session, 'order_updated');
      await EventService.broadcast(session, 'table_updated');
      return true;
    });
  }
}
