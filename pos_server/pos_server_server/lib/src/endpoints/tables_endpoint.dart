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

  Future<void> moveItemsToTable(
    Session session,
    List<int> itemIds,
    List<int> quantities,
    String targetTableNumber,
  ) async {
    if (itemIds.length != quantities.length) {
      throw Exception('Item IDs and quantities length mismatch');
    }

    await session.db.transaction((transaction) async {
      // 1. Find target order on target table (if exists, or create new)
      var targetOrder = await PosOrder.db.findFirstRow(
        session,
        where: (t) =>
            t.tableNo.equals(targetTableNumber) &
            t.status.inSet({'Pending', 'In Progress'}),
        transaction: transaction,
      );

      // Track source order IDs to update their totals and cleanup
      final sourceOrderIds = <int>{};

      // 2. Process each item move
      double movedTotal = 0;
      for (int i = 0; i < itemIds.length; i++) {
        final itemId = itemIds[i];
        final quantityToMove = quantities[i];

        final item = await OrderItem.db.findById(
          session,
          itemId,
          transaction: transaction,
        );
        if (item == null) continue;

        sourceOrderIds.add(item.orderId);

        // If target order doesn't exist yet, create it using the first item's source order info
        if (targetOrder == null) {
          final sourceOrder = await PosOrder.db.findById(
            session,
            item.orderId,
            transaction: transaction,
          );
          targetOrder = await PosOrder.db.insertRow(
            session,
            PosOrder(
              tableNo: targetTableNumber,
              status: 'Pending',
              orderType: sourceOrder?.orderType ?? 'Dine-In',
              waiterName: sourceOrder?.waiterName ?? 'System',
              total: 0,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              orderCode: 'ORD-S-${DateTime.now().millisecondsSinceEpoch}',
            ),
            transaction: transaction,
          );
        }

        if (quantityToMove >= item.quantity) {
          // Move the entire item
          movedTotal += item.totalPrice;
          await OrderItem.db.updateRow(
            session,
            item.copyWith(orderId: targetOrder.id!),
            transaction: transaction,
          );
        } else if (quantityToMove > 0) {
          // Split the item: reduce source quantity, create new target item
          final movedItemPrice = item.price * quantityToMove;
          movedTotal += movedItemPrice;

          // Update source item
          await OrderItem.db.updateRow(
            session,
            item.copyWith(
              quantity: item.quantity - quantityToMove,
              totalPrice: item.totalPrice - movedItemPrice,
            ),
            transaction: transaction,
          );

          // Create target item
          await OrderItem.db.insertRow(
            session,
            OrderItem(
              orderId: targetOrder.id!,
              productId: item.productId,
              productName: item.productName,
              productStation: item.productStation,
              quantity: quantityToMove,
              price: item.price,
              totalPrice: movedItemPrice,
              notes: item.notes,
              extras: item.extras,
            ),
            transaction: transaction,
          );
        }
      }

      // 3. Update target order total
      if (targetOrder != null) {
        await PosOrder.db.updateRow(
          session,
          targetOrder.copyWith(
            total: targetOrder.total + movedTotal,
            updatedAt: DateTime.now(),
          ),
          transaction: transaction,
        );
      }

      // 4. Update each source order and handle cleanup
      for (final sOrderId in sourceOrderIds) {
        final sOrder = await PosOrder.db.findById(
          session,
          sOrderId,
          transaction: transaction,
        );
        if (sOrder == null) continue;

        // Recalculate total for source order
        final remainingItems = await OrderItem.db.find(
          session,
          where: (t) => t.orderId.equals(sOrderId),
          transaction: transaction,
        );
        final newTotal = remainingItems.fold(
          0.0,
          (sum, it) => sum + it.totalPrice,
        );

        if (remainingItems.isEmpty) {
          // Delete empty order
          await PosOrder.db.deleteRow(
            session,
            sOrder,
            transaction: transaction,
          );

          // Check if table has no more orders
          final tableNo = sOrder.tableNo;
          if (tableNo != null) {
            final otherOrdersCount = await PosOrder.db.count(
              session,
              where: (t) =>
                  t.tableNo.equals(tableNo) &
                  t.status.inSet({'Pending', 'In Progress'}),
              transaction: transaction,
            );
            if (otherOrdersCount == 0) {
              final table = await RestaurantTable.db.findFirstRow(
                session,
                where: (t) => t.tableNumber.equals(tableNo),
                transaction: transaction,
              );
              if (table != null) {
                await RestaurantTable.db.updateRow(
                  session,
                  table.copyWith(
                    status: 'Available',
                    updatedAt: DateTime.now(),
                  ),
                  transaction: transaction,
                );
              }
            }
          }
        } else {
          // Update order total
          await PosOrder.db.updateRow(
            session,
            sOrder.copyWith(total: newTotal, updatedAt: DateTime.now()),
            transaction: transaction,
          );
        }
      }

      // 5. Update target table status
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
      } else {
        // User said "insert table" - if table doesn't exist, we create it
        await RestaurantTable.db.insertRow(
          session,
          RestaurantTable(
            tableNumber: targetTableNumber,
            status: 'Occupied',
            guestCount: 0,
            updatedAt: DateTime.now(),
          ),
          transaction: transaction,
        );
      }
    });

    await EventService.broadcast(session, 'table_updated');
    await EventService.broadcast(session, 'order_updated');
  }
}
