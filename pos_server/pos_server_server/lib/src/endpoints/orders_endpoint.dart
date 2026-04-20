import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../event_service.dart';

class OrdersEndpoint extends Endpoint {
  // ─── Helpers ───────────────────────────────────────────────────────────────

  Future<List<OrderItem>> _getItemsForOrder(
    Session session,
    int orderId,
  ) async {
    return await OrderItem.db.find(
      session,
      where: (t) => t.orderId.equals(orderId),
    );
  }

  Future<List<PosOrder>> _attachItems(
    Session session,
    List<PosOrder> orders, {
    String? stationFilter,
  }) async {
    if (orders.isEmpty) return orders;
    final orderIds = orders.map((o) => o.id!).toSet();

    var items = await OrderItem.db.find(
      session,
      where: (t) => t.orderId.inSet(orderIds),
    );

    if (stationFilter != null) {
      items = items.where((i) => i.productStation == stationFilter).toList();
    }

    final itemsByOrder = <int, List<OrderItem>>{};
    for (final item in items) {
      itemsByOrder.putIfAbsent(item.orderId, () => []).add(item);
    }

    if (stationFilter != null) {
      return orders
          .where((o) => (itemsByOrder[o.id!] ?? []).isNotEmpty)
          .map((o) => o.copyWith(items: itemsByOrder[o.id!]))
          .toList();
    }

    return orders
        .map((o) => o.copyWith(items: itemsByOrder[o.id!] ?? []))
        .toList();
  }

  // ─── Fetch ─────────────────────────────────────────────────────────────────

  Future<List<PosOrder>> getAll(
    Session session, {
    bool includeItems = false,
    String? statusFilter,
    String? stationFilter,
  }) async {
    final statusList = statusFilter?.split(',').map((s) => s.trim()).toList();

    var orders = await PosOrder.db.find(
      session,
      where: statusList != null
          ? (t) => t.status.inSet(statusList.toSet())
          : null,
      orderBy: (t) => t.createdAt,
      orderDescending: true,
    );

    if (includeItems) {
      orders = await _attachItems(
        session,
        orders,
        stationFilter: stationFilter,
      );
    }

    return orders;
  }

  Future<PosOrder> getById(Session session, int id) async {
    final order = await PosOrder.db.findById(session, id);
    if (order == null) throw Exception('Order not found');
    final items = await _getItemsForOrder(session, id);
    return order.copyWith(items: items);
  }

  // ─── Create ────────────────────────────────────────────────────────────────

  Future<PosOrder> create(
    Session session,
    double total,
    String? orderType,
    String? tableNo,
    String? orderCode,
    String? waiterName,
    List<OrderItem> items, {
    DateTime? scheduledTime,
  }) async {
    return await session.db.transaction<PosOrder>((txSession) async {
      // Auto-generate order code if not provided
      final finalOrderCode =
          orderCode ??
          'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      final now = DateTime.now();
      final status = scheduledTime != null ? 'Scheduled' : 'Pending';
      final order = PosOrder(
        total: total,
        subtotal: total,
        orderType: orderType,
        tableNo: tableNo,
        orderCode: finalOrderCode,
        waiterName: waiterName,
        status: status,
        scheduledTime: scheduledTime,
        createdAt: now,
        updatedAt: now,
      );
      final savedOrder = await PosOrder.db.insertRow(
        session,
        order,
        transaction: txSession,
      );

      // Insert order items
      for (final item in items) {
        final toInsert = OrderItem(
          orderId: savedOrder.id!,
          productId: item.productId,
          productName: item.productName,
          productStation: item.productStation,
          quantity: item.quantity,
          price: item.price,
          totalPrice: item.totalPrice,
          notes: item.notes,
          extras: item.extras,
        );
        await OrderItem.db.insertRow(session, toInsert, transaction: txSession);
      }

      // Mark table as occupied for dine-in
      if (orderType == 'Dine-In' && tableNo != null) {
        final tables = await RestaurantTable.db.find(
          session,
          where: (t) => t.tableNumber.equals(tableNo),
          limit: 1,
          transaction: txSession,
        );
        if (tables.isNotEmpty) {
          await RestaurantTable.db.updateRow(
            session,
            tables.first.copyWith(
              status: 'Occupied',
              orderCode: finalOrderCode,
              updatedAt: DateTime.now(),
            ),
            transaction: txSession,
          );
        } else {
          // If table doesn't exist, create it automatically
          await RestaurantTable.db.insertRow(
            session,
            RestaurantTable(
              tableNumber: tableNo,
              status: 'Occupied',
              orderCode: finalOrderCode,
              updatedAt: DateTime.now(),
              guestCount: 0,
            ),
            transaction: txSession,
          );
        }
      }

      await EventService.broadcast(session, 'order_created');
      await EventService.broadcast(session, 'table_updated');

      return savedOrder;
    });
  }

  // ─── Update Status ─────────────────────────────────────────────────────────

  Future<PosOrder> updateStatus(Session session, int id, String status) async {
    final existing = await PosOrder.db.findById(session, id);
    if (existing == null) throw Exception('Order not found');

    // If moving from Scheduled to anything else, and it's a Dine-In table, mark as occupied
    if (existing.status == 'Scheduled' &&
        status != 'Scheduled' &&
        existing.orderType == 'Dine-In' &&
        existing.tableNo != null) {
      final tables = await RestaurantTable.db.find(
        session,
        where: (t) => t.tableNumber.equals(existing.tableNo!),
        limit: 1,
      );
      if (tables.isNotEmpty) {
        await RestaurantTable.db.updateRow(
          session,
          tables.first.copyWith(
            status: 'Occupied',
            orderCode: existing.orderCode,
            updatedAt: DateTime.now(),
          ),
        );
        await EventService.broadcast(session, 'table_updated');
      }
    }

    // Normalize 'Mark Ready' -> 'Ready'
    final normalizedStatus = status == 'Mark Ready' ? 'Ready' : status;

    // If this order is already Paid (customer paid before food was ready),
    // and the kitchen is now marking it Ready or Served, complete the order.
    String finalStatus;
    if (existing.status == 'Paid') {
      final completionStatuses = {'Ready', 'Served', 'Mark Ready'};
      if (completionStatuses.contains(status)) {
        finalStatus = 'Completed';

        // Free up the table since the order is now complete
        if (existing.tableNo != null) {
          final otherActiveOrders = await PosOrder.db.find(
            session,
            where: (t) =>
                t.tableNo.equals(existing.tableNo!) &
                t.id.notEquals(existing.id!) &
                t.status.notEquals('Completed') &
                t.status.notEquals('Cancelled'),
          );

          if (otherActiveOrders.isEmpty) {
            final tables = await RestaurantTable.db.find(
              session,
              where: (t) => t.tableNumber.equals(existing.tableNo!),
              limit: 1,
            );
            if (tables.isNotEmpty) {
              await RestaurantTable.db.deleteRow(session, tables.first);
            }
          }
          await EventService.broadcast(session, 'table_updated');
        }
      } else {
        // Kitchen is starting work (Pending -> In Progress), keep as Paid
        finalStatus = 'Paid';
      }
    } else {
      finalStatus = normalizedStatus;
    }

    final updated = await PosOrder.db.updateRow(
      session,
      existing.copyWith(status: finalStatus, updatedAt: DateTime.now()),
    );
    await EventService.broadcast(session, 'order_updated');
    return updated;
  }

  // ─── Update ────────────────────────────────────────────────────────────────

  Future<PosOrder> update(Session session, PosOrder order) async {
    if (order.id == null) throw Exception('Order ID is required for update');
    final updated = await PosOrder.db.updateRow(
      session,
      order.copyWith(updatedAt: DateTime.now()),
    );
    await EventService.broadcast(session, 'order_updated');
    // Removed checkout_completed broadcast to avoid interfering with Kitchen/Bar orders
    return updated;
  }

  // ─── Merge ─────────────────────────────────────────────────────────────────

  Future<bool> merge(
    Session session,
    int targetOrderId,
    int sourceOrderId,
  ) async {
    return await session.db.transaction<bool>((txSession) async {
      final source = await PosOrder.db.findById(
        session,
        sourceOrderId,
        transaction: txSession,
      );
      if (source == null) throw Exception('Source order not found');
      final target = await PosOrder.db.findById(
        session,
        targetOrderId,
        transaction: txSession,
      );
      if (target == null) throw Exception('Target order not found');

      // Move all items to target
      final sourceItems = await OrderItem.db.find(
        session,
        where: (t) => t.orderId.equals(sourceOrderId),
        transaction: txSession,
      );
      for (final item in sourceItems) {
        await OrderItem.db.updateRow(
          session,
          item.copyWith(orderId: targetOrderId),
          transaction: txSession,
        );
      }

      // Add totals to target
      await PosOrder.db.updateRow(
        session,
        target.copyWith(
          subtotal: (target.subtotal) + (source.subtotal),
          taxAmount: (target.taxAmount) + (source.taxAmount),
          serviceAmount: (target.serviceAmount) + (source.serviceAmount),
          tipAmount: (target.tipAmount) + (source.tipAmount),
          total: target.total + source.total,
        ),
        transaction: txSession,
      );

      await PosOrder.db.deleteRow(session, source, transaction: txSession);

      await EventService.broadcast(session, 'order_updated');
      // Removed checkout_completed broadcast to avoid interfering with Kitchen/Bar orders
      return true;
    });
  }

  // ─── Split ─────────────────────────────────────────────────────────────────

  Future<int> split(
    Session session,
    int sourceOrderId,
    List<Map<String, dynamic>> splitItems,
    String newTableNo,
    String newOrderType,
    double sourceNewSubtotal,
    double sourceNewTax,
    double sourceNewService,
    double sourceNewTotal,
    double targetSubtotal,
    double targetTax,
    double targetService,
    double targetTotal,
  ) async {
    return await session.db.transaction<int>((txSession) async {
      final now = DateTime.now();
      final orderCode =
          'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      final newOrder = await PosOrder.db.insertRow(
        session,
        PosOrder(
          orderCode: orderCode,
          orderType: newOrderType,
          tableNo: newTableNo,
          status: 'In Progress',
          subtotal: targetSubtotal,
          taxAmount: targetTax,
          serviceAmount: targetService,
          tipAmount: 0,
          total: targetTotal,
          createdAt: now,
          updatedAt: now,
        ),
        transaction: txSession,
      );

      for (final splitItem in splitItems) {
        final itemId = splitItem['id'] as int;
        final qtyToMove = splitItem['quantityToMove'] as int;
        if (qtyToMove <= 0) continue;

        final existingList = await OrderItem.db.find(
          session,
          where: (t) => t.id.equals(itemId) & t.orderId.equals(sourceOrderId),
          limit: 1,
          transaction: txSession,
        );
        if (existingList.isEmpty) continue;
        final existing = existingList.first;

        if (existing.quantity == qtyToMove) {
          await OrderItem.db.updateRow(
            session,
            existing.copyWith(orderId: newOrder.id!),
            transaction: txSession,
          );
        } else {
          final remaining = existing.quantity - qtyToMove;
          await OrderItem.db.updateRow(
            session,
            existing.copyWith(
              quantity: remaining,
              totalPrice: remaining * existing.price,
            ),
            transaction: txSession,
          );
          await OrderItem.db.insertRow(
            session,
            OrderItem(
              orderId: newOrder.id!,
              productId: existing.productId,
              productName: existing.productName,
              productStation: existing.productStation,
              quantity: qtyToMove,
              price: existing.price,
              totalPrice: qtyToMove * existing.price,
              extras: existing.extras,
            ),
            transaction: txSession,
          );
        }
      }

      // Update source order totals
      final source = await PosOrder.db.findById(
        session,
        sourceOrderId,
        transaction: txSession,
      );
      if (source != null) {
        await PosOrder.db.updateRow(
          session,
          source.copyWith(
            subtotal: sourceNewSubtotal,
            taxAmount: sourceNewTax,
            serviceAmount: sourceNewService,
            total: sourceNewTotal,
          ),
          transaction: txSession,
        );
      }

      // Mark new table as occupied if dine-in
      if (newOrderType == 'Dine-In') {
        final tables = await RestaurantTable.db.find(
          session,
          where: (t) => t.tableNumber.equals(newTableNo),
          limit: 1,
          transaction: txSession,
        );
        if (tables.isNotEmpty) {
          await RestaurantTable.db.updateRow(
            session,
            tables.first.copyWith(
              status: 'Occupied',
              orderCode: orderCode,
              updatedAt: now,
            ),
            transaction: txSession,
          );
        } else {
          await RestaurantTable.db.insertRow(
            session,
            RestaurantTable(
              tableNumber: newTableNo,
              status: 'Occupied',
              orderCode: orderCode,
              updatedAt: now,
              guestCount: 0,
            ),
            transaction: txSession,
          );
        }
      }

      await EventService.broadcast(session, 'order_updated');
      await EventService.broadcast(session, 'table_updated');
      // Removed checkout_completed broadcast to avoid interfering with Kitchen/Bar orders
      return newOrder.id!;
    });
  }
}
