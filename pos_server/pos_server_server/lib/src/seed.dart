import 'package:serverpod/serverpod.dart';
import 'generated/protocol.dart';

/// Seeds default users into the database if they do not already exist.
Future<void> seedDatabase(Session session) async {
  final defaults = [
    PosUser(fullName: 'Admin User',       username: 'admin',   pin: '1111', role: 'Admin',   isDefault: true, status: 'Active', createdAt: DateTime.now()),
    PosUser(fullName: 'Waiter User',      username: 'waiter',  pin: '1234', role: 'Waiter',  isDefault: true, status: 'Active', createdAt: DateTime.now()),
    PosUser(fullName: 'Kitchen Display',  username: 'kitchen', pin: null,   role: 'Kitchen', isDefault: true, status: 'Active', createdAt: DateTime.now()),
    PosUser(fullName: 'Bar Display',      username: 'bar',     pin: null,   role: 'Bar',     isDefault: true, status: 'Active', createdAt: DateTime.now()),
    PosUser(fullName: 'Kiosk Display',    username: 'kiosk',   pin: null,   role: 'Kiosk',   isDefault: true, status: 'Active', createdAt: DateTime.now()),
  ];

  for (final user in defaults) {
    final existing = await PosUser.db.find(
      session,
      where: (t) => t.username.equals(user.username),
      limit: 1,
    );
    if (existing.isEmpty) {
      await PosUser.db.insertRow(session, user);
      session.log('Seeded user: ${user.username}');
    }
  }
}
