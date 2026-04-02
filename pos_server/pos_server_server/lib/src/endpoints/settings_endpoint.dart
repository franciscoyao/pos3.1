import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class SettingsEndpoint extends Endpoint {
  Future<Settings> getSettings(Session session) async {
    final settings = await Settings.db.findFirstRow(session);
    if (settings == null) {
      // Create default settings if not exists
      final defaults = Settings(
        taxRate: 0.0,
        serviceCharge: 0.0,
        currencySymbol: '€',
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
    try {
      await session.db.transaction((transaction) async {
        // 1. Delete transactional data
        await session.db.unsafeQuery(
          'DELETE FROM order_items',
          transaction: transaction,
        );
        await session.db.unsafeQuery(
          'DELETE FROM pos_orders',
          transaction: transaction,
        );
        await session.db.unsafeQuery(
          'DELETE FROM bills',
          transaction: transaction,
        );

        // 2. Delete master data
        await session.db.unsafeQuery(
          'DELETE FROM product_extras',
          transaction: transaction,
        );
        await session.db.unsafeQuery(
          'DELETE FROM products',
          transaction: transaction,
        );
        await session.db.unsafeQuery(
          'DELETE FROM subcategories',
          transaction: transaction,
        );
        await session.db.unsafeQuery(
          'DELETE FROM categories',
          transaction: transaction,
        );
        await session.db.unsafeQuery(
          'DELETE FROM pos_users WHERE "isDefault" = FALSE',
          transaction: transaction,
        );

        // 3. Reset tables
        await session.db.unsafeQuery(
          "UPDATE restaurant_tables SET status = 'Available', \"orderCode\" = NULL, \"guestCount\" = 0",
          transaction: transaction,
        );
      });

      return true;
    } catch (e) {
      session.log('Error purging data: $e', level: LogLevel.error);
      return false;
    }
  }

  Future<double> getDatabaseSize(Session session) async {
    // For now, return a dummy size (in MB)
    return 2.4;
  }

  Future<bool> clearAllTransactionalData(Session session) async {
    try {
      await session.db.transaction((transaction) async {
        // 1. Delete all order items
        await session.db.unsafeQuery(
          'DELETE FROM order_items',
          transaction: transaction,
        );

        // 2. Delete all orders
        await session.db.unsafeQuery(
          'DELETE FROM pos_orders',
          transaction: transaction,
        );

        // 3. Delete all bills
        await session.db.unsafeQuery(
          'DELETE FROM bills',
          transaction: transaction,
        );

        // 4. Reset all tables to Available
        await session.db.unsafeQuery(
          "UPDATE restaurant_tables SET status = 'Available', \"orderCode\" = NULL, \"guestCount\" = 0",
          transaction: transaction,
        );
      });

      return true;
    } catch (e) {
      session.log(
        'Error clearing transactional data: $e',
        level: LogLevel.error,
      );
      return false;
    }
  }
}
