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
}
