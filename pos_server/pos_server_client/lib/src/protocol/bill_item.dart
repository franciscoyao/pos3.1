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

abstract class BillItem implements _i1.SerializableModel {
  BillItem._({
    this.id,
    required this.billId,
    this.productName,
    required this.quantity,
    required this.price,
    double? totalPrice,
  }) : totalPrice = totalPrice ?? 0.0;

  factory BillItem({
    int? id,
    required int billId,
    String? productName,
    required int quantity,
    required double price,
    double? totalPrice,
  }) = _BillItemImpl;

  factory BillItem.fromJson(Map<String, dynamic> jsonSerialization) {
    return BillItem(
      id: jsonSerialization['id'] as int?,
      billId: jsonSerialization['billId'] as int,
      productName: jsonSerialization['productName'] as String?,
      quantity: jsonSerialization['quantity'] as int,
      price: (jsonSerialization['price'] as num).toDouble(),
      totalPrice: (jsonSerialization['totalPrice'] as num?)?.toDouble(),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int billId;

  String? productName;

  int quantity;

  double price;

  double totalPrice;

  /// Returns a shallow copy of this [BillItem]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  BillItem copyWith({
    int? id,
    int? billId,
    String? productName,
    int? quantity,
    double? price,
    double? totalPrice,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'BillItem',
      if (id != null) 'id': id,
      'billId': billId,
      if (productName != null) 'productName': productName,
      'quantity': quantity,
      'price': price,
      'totalPrice': totalPrice,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _BillItemImpl extends BillItem {
  _BillItemImpl({
    int? id,
    required int billId,
    String? productName,
    required int quantity,
    required double price,
    double? totalPrice,
  }) : super._(
         id: id,
         billId: billId,
         productName: productName,
         quantity: quantity,
         price: price,
         totalPrice: totalPrice,
       );

  /// Returns a shallow copy of this [BillItem]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  BillItem copyWith({
    Object? id = _Undefined,
    int? billId,
    Object? productName = _Undefined,
    int? quantity,
    double? price,
    double? totalPrice,
  }) {
    return BillItem(
      id: id is int? ? id : this.id,
      billId: billId ?? this.billId,
      productName: productName is String? ? productName : this.productName,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}
