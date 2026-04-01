import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../event_service.dart';

class ProductsEndpoint extends Endpoint {
  Future<List<Product>> getAll(Session session) async {
    final products = await Product.db.find(
      session,
      where: (t) => t.isDeleted.equals(false),
      orderBy: (t) => t.id,
    );

    // Attach extras
    if (products.isEmpty) return products;
    final productIds = products.map((p) => p.id!).toList();
    final extras = await ProductExtra.db.find(
      session,
      where: (t) => t.productId.inSet(productIds.toSet()),
    );
    final extrasByProduct = <int, List<ProductExtra>>{};
    for (final e in extras) {
      extrasByProduct.putIfAbsent(e.productId, () => []).add(e);
    }
    return products
        .map((p) => p.copyWith(extras: extrasByProduct[p.id!] ?? []))
        .toList();
  }

  Future<List<Product>> getPopular(Session session, String? orderType) async {
    // Return products ordered by quantity sold
    final result = await session.db.unsafeQuery(
      '''
      SELECT p.id
      FROM order_items oi
      JOIN pos_orders o ON oi."orderId" = o.id
      JOIN products p ON oi."productId" = p.id
      WHERE (p."isDeleted" = FALSE OR p."isDeleted" IS NULL)
      ${orderType != null ? 'AND (p.type = \$1 OR p.type = \'Both\' OR p.type IS NULL)' : ''}
      ${orderType != null ? 'AND o."orderType" = \$1' : ''}
      GROUP BY p.id
      ORDER BY SUM(oi.quantity) DESC
      LIMIT 10
      ''',
      parameters: orderType != null
          ? QueryParameters.positional([orderType])
          : null,
    );

    final ids = result.map((r) => r[0] as int).toList();
    if (ids.isEmpty) {
      return await Product.db.find(
        session,
        where: (t) =>
            t.isDeleted.equals(false) &
            ((orderType != null)
                ? (t.type.equals(orderType) |
                      t.type.equals('Both') |
                      t.type.equals(null))
                : Constant.bool(true)),
        limit: 10,
      );
    }

    final products = await Product.db.find(
      session,
      where: (t) => t.id.inSet(ids.toSet()),
    );
    final extras = await ProductExtra.db.find(
      session,
      where: (t) => t.productId.inSet(ids.toSet()),
    );
    final extrasByProduct = <int, List<ProductExtra>>{};
    for (final e in extras) {
      extrasByProduct.putIfAbsent(e.productId, () => []).add(e);
    }
    return products
        .map((p) => p.copyWith(extras: extrasByProduct[p.id!] ?? []))
        .toList();
  }

  Future<Product> create(Session session, Product product) async {
    final result = await Product.db.insertRow(session, product);
    await EventService.broadcast(session, 'product_updated');
    return result;
  }

  Future<Product> update(Session session, int id, Product product) async {
    final existing = await Product.db.findById(session, id);
    if (existing == null) throw Exception('Product not found');
    final updated = product.copyWith(id: id);
    final result = await Product.db.updateRow(session, updated);
    await EventService.broadcast(session, 'product_updated');
    return result;
  }

  Future<bool> delete(Session session, int id) async {
    final existing = await Product.db.findById(session, id);
    if (existing == null) throw Exception('Product not found');

    final usedInOrders = await OrderItem.db.find(
      session,
      where: (t) => t.productId.equals(id),
      limit: 1,
    );

    if (usedInOrders.isNotEmpty) {
      // Soft delete
      await Product.db.updateRow(session, existing.copyWith(isDeleted: true));
    } else {
      await ProductExtra.db.deleteWhere(
        session,
        where: (t) => t.productId.equals(id),
      );
      await Product.db.deleteRow(session, existing);
    }
    await EventService.broadcast(session, 'product_updated');
    return true;
  }

  Future<ProductExtra> addExtra(
    Session session,
    int productId,
    String name,
    double price,
  ) async {
    final extra = ProductExtra(productId: productId, name: name, price: price);
    final result = await ProductExtra.db.insertRow(session, extra);
    await EventService.broadcast(session, 'product_updated');
    return result;
  }

  Future<bool> deleteExtra(Session session, int extraId) async {
    final existing = await ProductExtra.db.findById(session, extraId);
    if (existing == null) throw Exception('Extra not found');
    await ProductExtra.db.deleteRow(session, existing);
    await EventService.broadcast(session, 'product_updated');
    return true;
  }
}
