import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../event_service.dart';

class CategoriesEndpoint extends Endpoint {
  Future<List<Category>> getAll(Session session) async {
    return await Category.db.find(
      session,
      orderBy: (t) => t.sortOrder,
      orderDescending: false,
    );
  }

  Future<Category> create(
    Session session,
    String name,
    int sortOrder,
    String? station,
    String orderType,
  ) async {
    final category = Category(
      name: name,
      sortOrder: sortOrder,
      station: station,
      orderType: orderType,
    );
    final result = await Category.db.insertRow(session, category);
    await EventService.broadcast(session, 'product_updated');
    return result;
  }

  Future<Category> update(
    Session session,
    int id,
    String name,
    int sortOrder,
    String? station,
    String orderType,
  ) async {
    final existing = await Category.db.findById(session, id);
    if (existing == null) throw Exception('Category not found');
    final updated = existing.copyWith(
      name: name,
      sortOrder: sortOrder,
      station: station,
      orderType: orderType,
    );
    final result = await Category.db.updateRow(session, updated);
    await EventService.broadcast(session, 'product_updated');
    return result;
  }

  Future<bool> delete(Session session, int id) async {
    final existing = await Category.db.findById(session, id);
    if (existing == null) throw Exception('Category not found');

    // Check if category has products
    final products = await Product.db.find(
      session,
      where: (t) => t.categoryId.equals(id),
      limit: 1,
    );
    if (products.isNotEmpty) {
      throw Exception('Cannot delete category because it contains menu items.');
    }

    await Category.db.deleteRow(session, existing);
    await EventService.broadcast(session, 'product_updated');
    return true;
  }
}
