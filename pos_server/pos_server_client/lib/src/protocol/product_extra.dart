/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

abstract class ProductExtra implements _i1.SerializableModel {
  ProductExtra._({
    this.id,
    required this.productId,
    required this.name,
    double? price,
  }) : price = price ?? 0.0;

  factory ProductExtra({
    int? id,
    required int productId,
    required String name,
    double? price,
  }) = _ProductExtraImpl;

  factory ProductExtra.fromJson(Map<String, dynamic> jsonSerialization) {
    return ProductExtra(
      id: jsonSerialization['id'] as int?,
      productId: jsonSerialization['productId'] as int,
      name: jsonSerialization['name'] as String,
      price: (jsonSerialization['price'] as num?)?.toDouble(),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int productId;

  String name;

  double price;

  /// Returns a shallow copy of this [ProductExtra]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ProductExtra copyWith({
    int? id,
    int? productId,
    String? name,
    double? price,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ProductExtra',
      if (id != null) 'id': id,
      'productId': productId,
      'name': name,
      'price': price,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ProductExtraImpl extends ProductExtra {
  _ProductExtraImpl({
    int? id,
    required int productId,
    required String name,
    double? price,
  }) : super._(
         id: id,
         productId: productId,
         name: name,
         price: price,
       );

  /// Returns a shallow copy of this [ProductExtra]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ProductExtra copyWith({
    Object? id = _Undefined,
    int? productId,
    String? name,
    double? price,
  }) {
    return ProductExtra(
      id: id is int? ? id : this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      price: price ?? this.price,
    );
  }
}
