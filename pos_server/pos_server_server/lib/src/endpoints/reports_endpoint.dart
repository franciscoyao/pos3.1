import 'package:serverpod/serverpod.dart';

class ReportSummaryData {
  final double totalRevenue;
  final int totalOrders;
  final double avgOrderValue;
  final List<Map<String, dynamic>> salesByDay;
  final List<Map<String, dynamic>> salesByCategory;
  final List<Map<String, dynamic>> topItems;

  ReportSummaryData({
    required this.totalRevenue,
    required this.totalOrders,
    required this.avgOrderValue,
    required this.salesByDay,
    required this.salesByCategory,
    required this.topItems,
  });
}

class ReportsEndpoint extends Endpoint {
  Future<String> getSummaryJson(Session session) async {
    // Overall stats from bills
    final statsResult = await session.db.unsafeQuery(
      'SELECT COALESCE(SUM(total), 0) AS total_revenue, COUNT(*) AS total_orders, COALESCE(AVG(total), 0) AS avg_order_value FROM bills',
    );
    final stats = statsResult.first;

    // Sales by day — last 7 days
    final salesByDayResult = await session.db.unsafeQuery('''
      SELECT
        TO_CHAR("createdAt"::date, 'YYYY-MM-DD') AS day,
        COALESCE(SUM(total), 0) AS revenue,
        COUNT(*) AS orders
      FROM bills
      WHERE "createdAt" >= NOW() - INTERVAL '7 days'
      GROUP BY "createdAt"::date
      ORDER BY "createdAt"::date ASC
    ''');

    // Sales by category
    final salesByCategoryResult = await session.db.unsafeQuery('''
      SELECT
        COALESCE(c.name, 'Uncategorized') AS category,
        COALESCE(SUM(oi.price * oi.quantity), 0) AS revenue
      FROM order_items oi
      JOIN products p ON oi."productId" = p.id
      LEFT JOIN categories c ON p."categoryId" = c.id
      GROUP BY c.name
      ORDER BY revenue DESC
    ''');

    // Top 5 selling products
    final topItemsResult = await session.db.unsafeQuery('''
      SELECT
        oi."productName" AS name,
        SUM(oi.quantity) AS total_qty,
        SUM(oi.price * oi.quantity) AS total_revenue
      FROM order_items oi
      GROUP BY oi."productName"
      ORDER BY total_qty DESC
      LIMIT 5
    ''');

    final salesByDay = salesByDayResult
        .map(
          (r) => {
            'day': r[0],
            'revenue': (r[1] as num).toDouble(),
            'orders': (r[2] as num).toInt(),
          },
        )
        .toList();

    final salesByCategory = salesByCategoryResult
        .map((r) => {'category': r[0], 'revenue': (r[1] as num).toDouble()})
        .toList();

    final topItems = topItemsResult
        .map(
          (r) => {
            'name': r[0],
            'total_qty': (r[1] as num).toInt(),
            'total_revenue': (r[2] as num).toDouble(),
          },
        )
        .toList();

    // Encode as JSON string so the client can decode it without a custom class
    final buffer = StringBuffer('{');
    buffer.write('"total_revenue":${(stats[0] as num).toDouble()},');
    buffer.write('"total_orders":${(stats[1] as num).toInt()},');
    buffer.write('"avg_order_value":${(stats[2] as num).toDouble()},');
    buffer.write('"sales_by_day":${_encodeList(salesByDay)},');
    buffer.write('"sales_by_category":${_encodeList(salesByCategory)},');
    buffer.write('"top_items":${_encodeList(topItems)}');
    buffer.write('}');
    return buffer.toString();
  }

  String _encodeList(List<Map<String, dynamic>> list) {
    final items = list.map((m) {
      final pairs = m.entries.map((e) {
        final val = e.value;
        if (val is String) return '"${e.key}":"$val"';
        return '"${e.key}":$val';
      });
      return '{${pairs.join(",")}}';
    });
    return '[${items.join(",")}]';
  }
}
