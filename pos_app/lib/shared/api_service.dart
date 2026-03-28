import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // ─── Server URL (configurable so all waiters/admin point at the same host) ──
  static Future<String> get baseUrl async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('server_url');
    if (saved != null && saved.trim().isNotEmpty) {
      return '${saved.trim()}/api';
    }
    if (kIsWeb) return 'http://localhost:3000/api';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:3000/api';
    } catch (_) {}
    return 'http://localhost:3000/api';
  }

  /// Save the server URL — e.g. http://192.168.1.50:3000
  static Future<void> saveServerUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_url', url.trim());
  }

  static Future<String> getSavedServerUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('server_url') ?? '';
  }

  // ─── Categories ──────────────────────────────────────────────
  Future<List<Category>> fetchCategories() async {
    final base = await baseUrl;
    final r = await http.get(Uri.parse('$base/categories'));
    if (r.statusCode == 200) {
      return (json.decode(r.body) as List).map((e) => Category.fromJson(e)).toList();
    }
    throw Exception('Failed to load categories');
  }

  Future<Category?> createCategory(String name, int sortOrder, String? station, String orderType) async {
    final base = await baseUrl;
    final r = await http.post(Uri.parse('$base/categories'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name, 'sort_order': sortOrder, 'station': station, 'order_type': orderType}));
    if (r.statusCode == 201) return Category.fromJson(json.decode(r.body));
    return null;
  }

  Future<Category?> updateCategory(int id, String name, int sortOrder, String? station, String orderType) async {
    final base = await baseUrl;
    final r = await http.put(Uri.parse('$base/categories/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name, 'sort_order': sortOrder, 'station': station, 'order_type': orderType}));
    if (r.statusCode == 200) return Category.fromJson(json.decode(r.body));
    return null;
  }

  Future<bool> deleteCategory(int id) async {
    final base = await baseUrl;
    final r = await http.delete(Uri.parse('$base/categories/$id'));
    return r.statusCode == 204;
  }

  // ─── Subcategories ───────────────────────────────────────────
  Future<List<Subcategory>> fetchSubcategories() async {
    final base = await baseUrl;
    final r = await http.get(Uri.parse('$base/subcategories'));
    if (r.statusCode == 200) {
      return (json.decode(r.body) as List).map((e) => Subcategory.fromJson(e)).toList();
    }
    throw Exception('Failed to load subcategories');
  }

  Future<Subcategory?> createSubcategory(int categoryId, String name, int sortOrder) async {
    final base = await baseUrl;
    final r = await http.post(Uri.parse('$base/subcategories'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'category_id': categoryId, 'name': name, 'sort_order': sortOrder}));
    if (r.statusCode == 201) return Subcategory.fromJson(json.decode(r.body));
    return null;
  }

  Future<Subcategory?> updateSubcategory(int id, int categoryId, String name, int sortOrder) async {
    final base = await baseUrl;
    final r = await http.put(Uri.parse('$base/subcategories/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'category_id': categoryId, 'name': name, 'sort_order': sortOrder}));
    if (r.statusCode == 200) return Subcategory.fromJson(json.decode(r.body));
    return null;
  }

  Future<bool> deleteSubcategory(int id) async {
    final base = await baseUrl;
    final r = await http.delete(Uri.parse('$base/subcategories/$id'));
    return r.statusCode == 204;
  }

  // ─── Products ────────────────────────────────────────────────
  Future<List<Product>> fetchProducts() async {
    final base = await baseUrl;
    final r = await http.get(Uri.parse('$base/products'));
    if (r.statusCode == 200) {
      return (json.decode(r.body) as List).map((e) => Product.fromJson(e)).toList();
    }
    throw Exception('Failed to load products');
  }

  Future<Product?> createProduct(Map<String, dynamic> data) async {
    final base = await baseUrl;
    final r = await http.post(Uri.parse('$base/products'),
        headers: {'Content-Type': 'application/json'}, body: json.encode(data));
    if (r.statusCode == 201) return Product.fromJson(json.decode(r.body));
    return null;
  }

  Future<Product?> updateProduct(int id, Map<String, dynamic> data) async {
    final base = await baseUrl;
    final r = await http.put(Uri.parse('$base/products/$id'),
        headers: {'Content-Type': 'application/json'}, body: json.encode(data));
    if (r.statusCode == 200) return Product.fromJson(json.decode(r.body));
    return null;
  }

  Future<bool> deleteProduct(int id) async {
    final base = await baseUrl;
    final r = await http.delete(Uri.parse('$base/products/$id'));
    return r.statusCode == 204;
  }

  Future<ProductExtra?> addProductExtra(int productId, String name, double price) async {
    final base = await baseUrl;
    final r = await http.post(Uri.parse('$base/products/$productId/extras'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name, 'price': price}));
    if (r.statusCode == 201) return ProductExtra.fromJson(json.decode(r.body));
    return null;
  }

  Future<bool> deleteProductExtra(int extraId) async {
    final base = await baseUrl;
    final r = await http.delete(Uri.parse('$base/products/extras/$extraId'));
    return r.statusCode == 204;
  }

  Future<List<Product>> fetchPopularProducts(String orderType) async {
    final base = await baseUrl;
    final uri = Uri.parse('$base/products/popular').replace(queryParameters: {'orderType': orderType});
    final r = await http.get(uri);
    if (r.statusCode == 200) {
      return (json.decode(r.body) as List).map((e) => Product.fromJson(e)).toList();
    }
    return [];
  }

  // ─── Tables ──────────────────────────────────────────────────
  Future<List<TableRecord>> fetchTables() async {
    final base = await baseUrl;
    final r = await http.get(Uri.parse('$base/tables'));
    if (r.statusCode == 200) {
      return (json.decode(r.body) as List).map((e) => TableRecord.fromJson(e)).toList();
    }
    throw Exception('Failed to load tables');
  }

  Future<TableRecord?> createTable(String tableNumber) async {
    final base = await baseUrl;
    final r = await http.post(Uri.parse('$base/tables'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'table_number': tableNumber}));
    if (r.statusCode == 201) return TableRecord.fromJson(json.decode(r.body));
    return null;
  }

  Future<TableRecord?> updateTable(int id, Map<String, dynamic> data) async {
    final base = await baseUrl;
    final r = await http.put(Uri.parse('$base/tables/$id'),
        headers: {'Content-Type': 'application/json'}, body: json.encode(data));
    if (r.statusCode == 200) return TableRecord.fromJson(json.decode(r.body));
    return null;
  }

  // ─── Orders ──────────────────────────────────────────────────
  Future<List<Order>> fetchOrders({bool includeItems = false, String? statusFilter, String? stationFilter}) async {
    final base = await baseUrl;
    final params = <String, String>{};
    if (includeItems) params['include_items'] = 'true';
    if (statusFilter != null) params['status'] = statusFilter;
    if (stationFilter != null) params['station'] = stationFilter;
    final uri = Uri.parse('$base/orders').replace(queryParameters: params.isEmpty ? null : params);
    final r = await http.get(uri);
    if (r.statusCode == 200) {
      return (json.decode(r.body) as List).map((e) => Order.fromJson(e)).toList();
    }
    throw Exception('Failed to load orders');
  }

  Future<Order> fetchOrderDetails(int id) async {
    final base = await baseUrl;
    final r = await http.get(Uri.parse('$base/orders/$id'));
    if (r.statusCode == 200) return Order.fromJson(json.decode(r.body));
    throw Exception('Failed to load order details');
  }

  Future<bool> submitOrder(double total, List<OrderItem> items,
      {String? orderType, String? tableNo, String? orderCode, String? waiterName}) async {
    final base = await baseUrl;
    final r = await http.post(Uri.parse('$base/orders'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'total': total,
          'order_type': orderType,
          'table_no': tableNo,
          'order_code': orderCode,
          'waiter_name': waiterName,
          'items': items.map((e) => {
            'product_id': e.product.id,
            'quantity': e.quantity,
            'price': e.unitPrice,
            'notes': e.notes,
            'extras': e.selectedExtras.map((ex) => ex.toJson()).toList(),
          }).toList(),
        }));
    return r.statusCode == 201;
  }

  Future<Order?> updateOrderStatus(int id, String status) async {
    final base = await baseUrl;
    final r = await http.put(Uri.parse('$base/orders/$id/status'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': status}));
    if (r.statusCode == 200) return Order.fromJson(json.decode(r.body));
    return null;
  }

  // ─── Checkout ────────────────────────────────────────────────
  Future<Bill?> checkout(int orderId, String paymentMethod, {String? waiterName}) async {
    final base = await baseUrl;
    final r = await http.post(Uri.parse('$base/checkout'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'order_id': orderId,
          'payment_method': paymentMethod,
          'waiter_name': waiterName,
        }));
    if (r.statusCode == 201) return Bill.fromJson(json.decode(r.body));
    return null;
  }

  // ─── Bills ───────────────────────────────────────────────────
  Future<List<Bill>> fetchBills() async {
    final base = await baseUrl;
    final r = await http.get(Uri.parse('$base/bills'));
    if (r.statusCode == 200) {
      return (json.decode(r.body) as List).map((e) => Bill.fromJson(e)).toList();
    }
    throw Exception('Failed to load bills');
  }

  Future<Bill> fetchBillDetails(int id) async {
    final base = await baseUrl;
    final r = await http.get(Uri.parse('$base/bills/$id/details'));
    if (r.statusCode == 200) return Bill.fromJson(json.decode(r.body));
    throw Exception('Failed to load bill details');
  }

  // ─── Users ───────────────────────────────────────────────────
  Future<List<User>> fetchUsers() async {
    final base = await baseUrl;
    final r = await http.get(Uri.parse('$base/users'));
    if (r.statusCode == 200) {
      return (json.decode(r.body) as List).map((e) => User.fromJson(e)).toList();
    }
    throw Exception('Failed to load users');
  }

  Future<User?> createUser(Map<String, dynamic> data) async {
    final base = await baseUrl;
    final r = await http.post(Uri.parse('$base/users'),
        headers: {'Content-Type': 'application/json'}, body: json.encode(data));
    if (r.statusCode == 201) return User.fromJson(json.decode(r.body));
    return null;
  }

  Future<User?> updateUser(int id, Map<String, dynamic> data) async {
    final base = await baseUrl;
    final r = await http.put(Uri.parse('$base/users/$id'),
        headers: {'Content-Type': 'application/json'}, body: json.encode(data));
    if (r.statusCode == 200) return User.fromJson(json.decode(r.body));
    return null;
  }

  Future<bool> deleteUser(int id) async {
    final base = await baseUrl;
    final r = await http.delete(Uri.parse('$base/users/$id'));
    return r.statusCode == 204;
  }

  Future<User?> login(String role, {String? username, String? pin}) async {
    try {
      final base = await baseUrl;
      final r = await http.post(Uri.parse('$base/login'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'role': role, 'username': username, 'pin': pin}));
      if (r.statusCode == 200) {
        final data = json.decode(r.body);
        if (data['success'] == true && data['user'] != null) {
          return User.fromJson(data['user']);
        }
      }
      return null;
    } catch (e) { return null; }
  }

  // ─── Reports ─────────────────────────────────────────────────
  Future<ReportSummary> fetchReportSummary() async {
    final base = await baseUrl;
    final r = await http.get(Uri.parse('$base/reports/summary'));
    if (r.statusCode == 200) return ReportSummary.fromJson(json.decode(r.body));
    throw Exception('Failed to load reports');
  }
  // ─── Merge & Split ───────────────────────────────────────────
  Future<bool> mergeOrders(int targetOrderId, int sourceOrderId) async {
    try {
      final base = await baseUrl;
      final res = await http.post(
        Uri.parse('$base/orders/merge'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'targetOrderId': targetOrderId,
          'sourceOrderId': sourceOrderId,
        }),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<int?> splitOrder({
    required int sourceOrderId,
    required List<Map<String, dynamic>> splitItems, // { id, quantityToMove }
    required String newTableNo,
    required String newOrderType,
    required double sourceNewSubtotal,
    required double sourceNewTax,
    required double sourceNewService,
    required double sourceNewTotal,
    required double targetSubtotal,
    required double targetTax,
    required double targetService,
    required double targetTotal,
  }) async {
    try {
      final base = await baseUrl;
      final res = await http.post(
        Uri.parse('$base/orders/$sourceOrderId/split'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'splitItems': splitItems,
          'newTableNo': newTableNo,
          'newOrderType': newOrderType,
          'sourceNewSubtotal': sourceNewSubtotal,
          'sourceNewTax': sourceNewTax,
          'sourceNewService': sourceNewService,
          'sourceNewTotal': sourceNewTotal,
          'targetSubtotal': targetSubtotal,
          'targetTax': targetTax,
          'targetService': targetService,
          'targetTotal': targetTotal,
        }),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['newOrderId']; // Can be null if API doesn't return it
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
