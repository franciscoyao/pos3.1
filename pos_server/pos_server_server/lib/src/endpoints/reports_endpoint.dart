import 'package:serverpod/serverpod.dart';
import 'dart:convert';

class ReportsEndpoint extends Endpoint {
  Future<String> getSummaryJson(Session session) async {
    try {
      // Overall stats from bills
      List<List<dynamic>> statsResult;
      try {
        statsResult = await session.db.unsafeQuery(
          'SELECT COALESCE(SUM(total), 0.0) AS total_revenue, COUNT(*) AS total_orders, COALESCE(AVG(total), 0.0) AS avg_order_value FROM bills',
        );
      } catch (e) {
        session.log('Error in stats query: $e', level: LogLevel.error);
        statsResult = [];
      }

      final stats = statsResult.isNotEmpty ? statsResult.first : [0.0, 0, 0.0];

      // Sales by day — last 7 days
      List<List<dynamic>> salesByDayResult;
      try {
        salesByDayResult = await session.db.unsafeQuery('''
          SELECT 
            TO_CHAR("createdAt"::date, 'YYYY-MM-DD') AS day,
            COALESCE(SUM(total), 0.0) AS revenue,
            COUNT(*) AS orders
          FROM bills
          WHERE "createdAt" >= NOW() - INTERVAL '7 days'
          GROUP BY "createdAt"::date
          ORDER BY "createdAt"::date ASC
        ''');
      } catch (e) {
        session.log('Error in sales by day query: $e', level: LogLevel.error);
        salesByDayResult = [];
      }

      // Sales by category
      List<List<dynamic>> salesByCategoryResult;
      try {
        salesByCategoryResult = await session.db.unsafeQuery('''
          SELECT 
            COALESCE(c.name, 'Uncategorized') AS category,
            COALESCE(SUM(oi.price * oi.quantity), 0.0) AS revenue
          FROM order_items oi
          JOIN products p ON oi."productId" = p.id
          LEFT JOIN categories c ON p."categoryId" = c.id
          GROUP BY COALESCE(c.name, 'Uncategorized')
          ORDER BY revenue DESC
        ''');
      } catch (e) {
        session.log(
          'Error in sales by category query: $e',
          level: LogLevel.error,
        );
        salesByCategoryResult = [];
      }

      // Top 5 selling products
      List<List<dynamic>> topItemsResult;
      try {
        topItemsResult = await session.db.unsafeQuery('''
          SELECT 
            COALESCE(oi."productName", 'Unknown') AS name,
            SUM(oi.quantity) AS total_qty,
            SUM(oi.price * oi.quantity) AS total_revenue
          FROM order_items oi
          GROUP BY COALESCE(oi."productName", 'Unknown')
          ORDER BY total_qty DESC
          LIMIT 5
        ''');
      } catch (e) {
        session.log('Error in top items query: $e', level: LogLevel.error);
        topItemsResult = [];
      }

      final salesByDay = salesByDayResult.map((r) {
        return {
          'day': r[0]?.toString() ?? '',
          'revenue': _toDouble(r[1]),
          'orders': _toInt(r[2]),
        };
      }).toList();

      final salesByCategory = salesByCategoryResult.map((r) {
        return {
          'category': r[0]?.toString() ?? 'Uncategorized',
          'revenue': _toDouble(r[1]),
        };
      }).toList();

      final topItems = topItemsResult.map((r) {
        return {
          'name': r[0]?.toString() ?? 'Unknown',
          'total_qty': _toInt(r[1]),
          'total_revenue': _toDouble(r[2]),
        };
      }).toList();

      final result = {
        'total_revenue': _toDouble(stats[0]),
        'total_orders': _toInt(stats[1]),
        'avg_order_value': _toDouble(stats[2]),
        'sales_by_day': salesByDay,
        'sales_by_category': salesByCategory,
        'top_items': topItems,
      };

      return json.encode(result);
    } catch (e, stackTrace) {
      session.log(
        'Error in getSummaryJson: $e',
        level: LogLevel.error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

// Removed the old _encodeList and manual buffer building logic.
// Removed ReportSummaryData class as it was unused in the endpoint return type.
