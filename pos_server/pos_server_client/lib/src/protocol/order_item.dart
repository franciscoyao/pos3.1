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

abstract class OrderItem implements _i1.SerializableModel {
  OrderItem._({
    this.id,
    required this.orderId,
    required this.productId,
    this.productName,
    this.productStation,
    required this.quantity,
    required this.price,
    double? totalPrice,
    this.notes,
    String? extras,
  }) : totalPrice = totalPrice ?? 0.0,
       extras = extras ?? '[]';

  factory OrderItem({
    int? id,
    required int orderId,
    required int productId,
    String? productName,
    String? productStation,
    required int quantity,
    required double price,
    double? totalPrice,
    String? notes,
    String? extras,
  }) = _OrderItemImpl;

  factory OrderItem.fromJson(Map<String, dynamic> jsonSerialization) {
    return OrderItem(
      id: jsonSerialization['id'] as int?,
      orderId: jsonSerialization['orderId'] as int,
      productId: jsonSerialization['productId'] as int,
      productName: jsonSerialization['productName'] as String?,
      productStation: jsonSerialization['productStation'] as String?,
      quantity: jsonSerialization['quantity'] as int,
      price: (jsonSerialization['price'] as num).toDouble(),
      totalPrice: (jsonSerialization['totalPrice'] as num?)?.toDouble(),
      notes: jsonSerialization['notes'] as String?,
      extras: jsonSerialization['extras'] as String?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int orderId;

  int productId;

  String? productName;

  String? productStation;

  int quantity;

  double price;

  double totalPrice;

  String? notes;

  String? extras;

  /// Returns a shallow copy of this [OrderItem]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  OrderItem copyWith({
    int? id,
    int? orderId,
    int? productId,
    String? productName,
    String? productStation,
    int? quantity,
    double? price,
    double? totalPrice,
    String? notes,
    String? extras,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'OrderItem',
      if (id != null) 'id': id,
      'orderId': orderId,
      'productId': productId,
      if (productName != null) 'productName': productName,
      if (productStation != null) 'productStation': productStation,
      'quantity': quantity,
      'price': price,
      'totalPrice': totalPrice,
      if (notes != null) 'notes': notes,
      if (extras != null) 'extras': extras,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _OrderItemImpl extends OrderItem {
  _OrderItemImpl({
    int? id,
    required int orderId,
    required int productId,
    String? productName,
    String? productStation,
    required int quantity,
    required double price,
    double? totalPrice,
    String? notes,
    String? extras,
  }) : super._(
         id: id,
         orderId: orderId,
         productId: productId,
         productName: productName,
         productStation: productStation,
         quantity: quantity,
         price: price,
         totalPrice: totalPrice,
         notes: notes,
         extras: extras,
       );

  /// Returns a shallow copy of this [OrderItem]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  OrderItem copyWith({
    Object? id = _Undefined,
    int? orderId,
    int? productId,
    Object? productName = _Undefined,
    Object? productStation = _Undefined,
    int? quantity,
    double? price,
    double? totalPrice,
    Object? notes = _Undefined,
    Object? extras = _Undefined,
  }) {
    return OrderItem(
      id: id is int? ? id : this.id,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      productName: productName is String? ? productName : this.productName,
      productStation: productStation is String?
          ? productStation
          : this.productStation,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      totalPrice: totalPrice ?? this.totalPrice,
      notes: notes is String? ? notes : this.notes,
      extras: extras is String? ? extras : this.extras,
    );
  }
}
