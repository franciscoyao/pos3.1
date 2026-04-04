import 'package:serverpod/serverpod.dart';
import 'generated/protocol.dart';
import 'event_service.dart';

class ScheduledOrderCall extends FutureCall {
  @override
  Future<void> invoke(Session session, SerializableModel? object) async {
    try {
      final now = DateTime.now();
      // 1. Find all 'Scheduled' orders that should have started by now
      final scheduledOrders = await PosOrder.db.find(
        session,
        where: (t) => t.status.equals('Scheduled') & (t.scheduledTime < now),
      );

      if (scheduledOrders.isNotEmpty) {
        for (final order in scheduledOrders) {
          await session.db.transaction((transaction) async {
            // 2. Update order status to 'Pending'
            await PosOrder.db.updateRow(
              session,
              order.copyWith(
                status: 'Pending',
                updatedAt: now,
              ),
              transaction: transaction,
            );

            // 3. If it's a Dine-In table, mark the table as 'Occupied'
            if (order.orderType == 'Dine-In' && order.tableNo != null) {
              final tables = await RestaurantTable.db.find(
                session,
                where: (t) => t.tableNumber.equals(order.tableNo!),
                limit: 1,
                transaction: transaction,
              );

              if (tables.isNotEmpty) {
                await RestaurantTable.db.updateRow(
                  session,
                  tables.first.copyWith(
                    status: 'Occupied',
                    orderCode: order.orderCode,
                    updatedAt: now,
                  ),
                  transaction: transaction,
                );
              } else {
                // Create table if it doesn't exist
                await RestaurantTable.db.insertRow(
                  session,
                  RestaurantTable(
                    tableNumber: order.tableNo!,
                    status: 'Occupied',
                    orderCode: order.orderCode,
                    guestCount: 0,
                    updatedAt: now,
                  ),
                  transaction: transaction,
                );
              }
            }
          });
        }

        // 4. Broadcast events so frontend updates in real-time
        await EventService.broadcast(session, 'order_updated');
        await EventService.broadcast(session, 'table_updated');

        session.log(
          'ScheduledOrderCall: Activated ${scheduledOrders.length} orders.',
        );
      }
    } catch (e, stackTrace) {
      session.log(
        'ScheduledOrderCall: Error activating orders: $e',
        level: LogLevel.error,
        stackTrace: stackTrace,
      );
    } finally {
      // 5. Schedule next run in 1 minute
      // ignore: deprecated_member_use
      await session.serverpod.futureCallWithDelay(
        'scheduledOrderCall',
        null,
        const Duration(minutes: 1),
      );
    }
  }
}
