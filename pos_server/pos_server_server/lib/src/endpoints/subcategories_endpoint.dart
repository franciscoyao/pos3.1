import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../event_service.dart';

class SubcategoriesEndpoint extends Endpoint {
  Future<List<Subcategory>> getAll(Session session) async {
    return await Subcategory.db.find(
      session,
      orderBy: (t) => t.sortOrder,
      orderDescending: false,
    );
  }

  Future<Subcategory> create(
    Session session,
    int categoryId,
    String name,
    int sortOrder,
  ) async {
    final sub = Subcategory(categoryId: categoryId, name: name, sortOrder: sortOrder);
    final result = await Subcategory.db.insertRow(session, sub);
    await EventService.broadcast(session, 'product_updated');
    return result;
  }

  Future<Subcategory> update(
    Session session,
    int id,
    int categoryId,
    String name,
    int sortOrder,
  ) async {
    final existing = await Subcategory.db.findById(session, id);
    if (existing == null) throw Exception('Subcategory not found');
    final updated = existing.copyWith(categoryId: categoryId, name: name, sortOrder: sortOrder);
    final result = await Subcategory.db.updateRow(session, updated);
    await EventService.broadcast(session, 'product_updated');
    return result;
  }

  Future<bool> delete(Session session, int id) async {
    final existing = await Subcategory.db.findById(session, id);
    if (existing == null) throw Exception('Subcategory not found');
    await Subcategory.db.deleteRow(session, existing);
    await EventService.broadcast(session, 'product_updated');
    return true;
  }
}
