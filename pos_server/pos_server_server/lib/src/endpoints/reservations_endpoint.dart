import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../event_service.dart';

class ReservationsEndpoint extends Endpoint {
  Future<List<Reservation>> getAll(Session session) async {
    return await Reservation.db.find(
      session,
      orderBy: (t) => t.reservationTime,
    );
  }

  Future<Reservation> create(Session session, Reservation reservation) async {
    final now = DateTime.now();
    final toCreate = reservation.copyWith(
      createdAt: now,
      updatedAt: now,
    );
    final result = await Reservation.db.insertRow(session, toCreate);
    await EventService.broadcast(session, 'reservation_updated');
    return result;
  }

  Future<Reservation> update(Session session, Reservation reservation) async {
    if (reservation.id == null) {
      session.log('Reservation update failed: reservation.id is null');
      throw Exception('Reservation id is required for update');
    }
    final existing = await Reservation.db.findById(session, reservation.id!);
    if (existing == null) {
      session.log('Reservation update failed: ID ${reservation.id} not found');
      throw Exception('Reservation not found');
    }

    final toUpdate = reservation.copyWith(
      updatedAt: DateTime.now(),
    );
    final result = await Reservation.db.updateRow(session, toUpdate);
    await EventService.broadcast(session, 'reservation_updated');
    return result;
  }

  Future<bool> delete(Session session, int id) async {
    final reservation = await Reservation.db.findById(session, id);
    if (reservation == null) return false;

    await Reservation.db.deleteRow(session, reservation);
    await EventService.broadcast(session, 'reservation_updated');
    return true;
  }

  Future<List<Reservation>> getByTable(
    Session session,
    String tableNumber,
  ) async {
    return await Reservation.db.find(
      session,
      where: (t) => t.tableNumber.equals(tableNumber),
      orderBy: (t) => t.reservationTime,
    );
  }

  Future<Reservation> markAsArrived(Session session, int id) async {
    final reservation = await Reservation.db.findById(session, id);
    if (reservation == null) throw Exception('Reservation not found');

    final updated = reservation.copyWith(
      status: 'Arrived',
      updatedAt: DateTime.now(),
    );
    final result = await Reservation.db.updateRow(session, updated);
    await EventService.broadcast(session, 'reservation_updated');
    return result;
  }
}
