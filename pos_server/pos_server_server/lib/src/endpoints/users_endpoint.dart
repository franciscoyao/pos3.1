import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class UsersEndpoint extends Endpoint {
  Future<List<PosUser>> getAll(Session session) async {
    return await PosUser.db.find(session, orderBy: (t) => t.id);
  }

  Future<PosUser> create(Session session, PosUser user) async {
    final toInsert = user.copyWith(createdAt: DateTime.now());
    return await PosUser.db.insertRow(session, toInsert);
  }

  Future<PosUser> update(Session session, int id, PosUser user) async {
    final existing = await PosUser.db.findById(session, id);
    if (existing == null) throw Exception('User not found');

    // Preserve fields that shouldn't be overwritten by client if null
    final updated = user.copyWith(
      id: id,
      createdAt: existing.createdAt,
      isDefault: existing.isDefault,
    );
    return await PosUser.db.updateRow(session, updated);
  }

  Future<bool> delete(Session session, int id) async {
    final existing = await PosUser.db.findById(session, id);
    if (existing == null) throw Exception('User not found');
    if (existing.isDefault) throw Exception('Cannot delete default users');
    await PosUser.db.deleteRow(session, existing);
    return true;
  }

  Future<PosUser?> login(
    Session session,
    String role,
    String? username,
    String? pin,
  ) async {
    if (role == 'Admin' || role == 'Waiter') {
      if (username == null || pin == null) {
        throw Exception('Username and PIN required');
      }
      final users = await PosUser.db.find(
        session,
        where: (t) =>
            t.username.equals(username) &
            t.pin.equals(pin) &
            t.role.equals(role) &
            t.status.equals('Active'),
        limit: 1,
      );
      return users.isEmpty ? null : users.first;
    } else {
      final users = await PosUser.db.find(
        session,
        where: (t) => t.role.equals(role) & t.status.equals('Active'),
        limit: 1,
      );
      return users.isEmpty ? null : users.first;
    }
  }
}
