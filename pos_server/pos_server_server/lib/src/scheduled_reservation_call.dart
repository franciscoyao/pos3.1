import 'dart:math';

import 'package:serverpod/serverpod.dart';
import 'generated/protocol.dart';
import 'event_service.dart';

class ScheduledReservationCall extends FutureCall {
  @override
  Future<void> invoke(Session session, SerializableModel? object) async {
    try {
      final now = DateTime.now();
      // 1. Find all reservations that are pending or confirmed that have arrived
      final dueReservations = await Reservation.db.find(
        session,
        where: (t) =>
            (t.reservationTime <= now) &
            (t.status.equals('Pending') | t.status.equals('Confirmed')),
      );

      if (dueReservations.isNotEmpty) {
        for (final res in dueReservations) {
          await session.db.transaction((transaction) async {
            // 2. Generate a unique order code for the new POS Order
            int randomSuffix = Random().nextInt(900000) + 100000;
            final orderCode = 'RES-${res.id ?? "X"}-$randomSuffix';

            // 3. Update reservation status to 'Completed' (since GUI uses Completed for arriving)
            await Reservation.db.updateRow(
              session,
              res.copyWith(
                status: 'Completed',
                updatedAt: now,
              ),
              transaction: transaction,
            );

            // 4. Update or Create RestaurantTable
            final tables = await RestaurantTable.db.find(
              session,
              where: (t) => t.tableNumber.equals(res.tableNumber),
              limit: 1,
              transaction: transaction,
            );

            if (tables.isNotEmpty) {
              await RestaurantTable.db.updateRow(
                session,
                tables.first.copyWith(
                  status: 'Occupied',
                  guestCount: res.guestCount,
                  orderCode: orderCode,
                  updatedAt: now,
                ),
                transaction: transaction,
              );
            } else {
              await RestaurantTable.db.insertRow(
                session,
                RestaurantTable(
                  tableNumber: res.tableNumber,
                  status: 'Occupied',
                  orderCode: orderCode,
                  guestCount: res.guestCount,
                  updatedAt: now,
                ),
                transaction: transaction,
              );
            }

            // 5. Create active POS Order
            await PosOrder.db.insertRow(
              session,
              PosOrder(
                orderCode: orderCode,
                orderType: 'Dine-In',
                tableNo: res.tableNumber,
                status: 'Pending', // Order is pending payment
                total: 0,
                subtotal: 0,
                taxAmount: 0,
                serviceAmount: 0,
                tipAmount: 0,
                createdAt: now,
                updatedAt: now,
              ),
              transaction: transaction,
            );
          });
        }

        // 6. Broadcast updates
        await EventService.broadcast(session, 'reservation_updated');
        await EventService.broadcast(session, 'table_updated');
        await EventService.broadcast(session, 'order_updated');

        session.log(
          'ScheduledReservationCall: Activated ${dueReservations.length} reservations.',
        );
      }
    } catch (e, stackTrace) {
      session.log(
        'ScheduledReservationCall: Error processing reservations: $e',
        level: LogLevel.error,
        stackTrace: stackTrace,
      );
    } finally {
      // 7. Schedule next run in 1 minute
      // ignore: deprecated_member_use
      await session.serverpod.futureCallWithDelay(
        'scheduledReservationCall',
        null,
        const Duration(minutes: 1),
      );
    }
  }
}
