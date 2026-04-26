import 'dart:async';
import 'package:pos_server_client/pos_server_client.dart';

class DataCache {
  static final DataCache instance = DataCache._init();
  DataCache._init();

  List<Product>? _products;
  List<Category>? _categories;
  List<RestaurantTable>? _tables;
  final Map<String, List<Product>> _popularProducts = {};

  Future<List<Product>>? _productsFuture;
  Future<List<Category>>? _categoriesFuture;
  Future<List<RestaurantTable>>? _tablesFuture;
  final Map<String, Future<List<Product>>> _popularFutures = {};

  void invalidateProducts() {
    _products = null;
    _productsFuture = null;
    _popularProducts.clear();
    _popularFutures.clear();
  }

  void invalidateCategories() {
    _categories = null;
    _categoriesFuture = null;
  }

  void invalidateTables() {
    _tables = null;
    _tablesFuture = null;
  }

  void handlePosEvent(PosEvent event) {
    if (event.eventType == 'product_updated' || event.eventType == 'category_updated') {
      invalidateProducts();
      invalidateCategories();
    }
    if (event.eventType == 'table_updated') {
      invalidateTables();
    }
  }

  Future<List<Product>> getProducts(Client client, {bool forceRefresh = false}) {
    if (forceRefresh) invalidateProducts();
    if (_products != null) return Future.value(_products!);
    if (_productsFuture != null) return _productsFuture!;

    _productsFuture = client.products.getAll().then((data) {
      _products = data;
      _productsFuture = null;
      return data;
    }).catchError((e) {
      _productsFuture = null;
      throw e;
    });
    return _productsFuture!;
  }

  Future<List<Category>> getCategories(Client client, {bool forceRefresh = false}) {
    if (forceRefresh) invalidateCategories();
    if (_categories != null) return Future.value(_categories!);
    if (_categoriesFuture != null) return _categoriesFuture!;

    _categoriesFuture = client.categories.getAll().then((data) {
      _categories = data;
      _categoriesFuture = null;
      return data;
    }).catchError((e) {
      _categoriesFuture = null;
      throw e;
    });
    return _categoriesFuture!;
  }

  Future<List<RestaurantTable>> getTables(Client client, {bool forceRefresh = false}) {
    if (forceRefresh) invalidateTables();
    if (_tables != null) return Future.value(_tables!);
    if (_tablesFuture != null) return _tablesFuture!;

    _tablesFuture = client.tables.getAll().then((data) {
      _tables = data;
      _tablesFuture = null;
      return data;
    }).catchError((e) {
      _tablesFuture = null;
      throw e;
    });
    return _tablesFuture!;
  }

  Future<List<Product>> getPopularProducts(Client client, String orderType, {bool forceRefresh = false}) {
    if (forceRefresh) invalidateProducts();
    if (_popularProducts.containsKey(orderType)) {
      return Future.value(_popularProducts[orderType]!);
    }
    if (_popularFutures.containsKey(orderType)) {
      return _popularFutures[orderType]!;
    }

    final future = client.products.getPopular(orderType).then((data) {
      _popularProducts[orderType] = data;
      _popularFutures.remove(orderType);
      return data;
    }).catchError((e) {
      _popularFutures.remove(orderType);
      throw e;
    });
    _popularFutures[orderType] = future;
    return future;
  }
}
