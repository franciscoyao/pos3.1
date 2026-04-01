import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class SettingsEndpoint extends Endpoint {
  Future<Settings> getSettings(Session session) async {
    final settings = await Settings.db.findFirstRow(session);
    if (settings == null) {
      // Create default settings if not exists
      final defaults = Settings(
        taxRate: 10.0,
        serviceCharge: 5.0,
        currencySymbol: '\$',
        orderDelayThreshold: 15,
        updatedAt: DateTime.now(),
      );
      return await Settings.db.insertRow(session, defaults);
    }
    return settings;
  }

  Future<Settings> updateSettings(Session session, Settings settings) async {
    final existing = await Settings.db.findFirstRow(session);
    if (existing == null) {
      return await Settings.db.insertRow(
        session,
        settings.copyWith(updatedAt: DateTime.now()),
      );
    }
    final toUpdate = settings.copyWith(
      id: existing.id,
      updatedAt: DateTime.now(),
    );
    return await Settings.db.updateRow(session, toUpdate);
  }

  Future<bool> backupDatabase(Session session) async {
    // In a real scenario, this would trigger a database dump.
    // For now, we simulate success.
    session.log('Database backup triggered');
    return true;
  }

  Future<bool> restoreDatabase(Session session) async {
    // In a real scenario, this would restore from a dump.
    session.log('Database restore triggered');
    return true;
  }

  Future<bool> purgeOldData(Session session, int days) async {
    // Logic to delete old orders/bills
    final cutoff = DateTime.now().subtract(Duration(days: days));
    // Implementation would depend on how we define "old data"
    session.log(
      'Purging data older than $days days (cutoff: ${cutoff.toIso8601String()})',
    );
    return true;
  }

  Future<double> getDatabaseSize(Session session) async {
    // For now, return a dummy size (in MB)
    return 2.4;
  }
}
