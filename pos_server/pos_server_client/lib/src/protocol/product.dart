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
import 'product_extra.dart' as _i2;
import 'package:pos_server_client/src/protocol/protocol.dart' as _i3;

abstract class Product implements _i1.SerializableModel {
  Product._({
    this.id,
    this.categoryId,
    this.subcategoryId,
    this.itemCode,
    required this.name,
    required this.price,
    this.imageUrl,
    this.station,
    this.type,
    bool? isAvailable,
    bool? allowPriceEdit,
    bool? isDeleted,
    this.extras,
  }) : isAvailable = isAvailable ?? true,
       allowPriceEdit = allowPriceEdit ?? false,
       isDeleted = isDeleted ?? false;

  factory Product({
    int? id,
    int? categoryId,
    int? subcategoryId,
    String? itemCode,
    required String name,
    required double price,
    String? imageUrl,
    String? station,
    String? type,
    bool? isAvailable,
    bool? allowPriceEdit,
    bool? isDeleted,
    List<_i2.ProductExtra>? extras,
  }) = _ProductImpl;

  factory Product.fromJson(Map<String, dynamic> jsonSerialization) {
    return Product(
      id: jsonSerialization['id'] as int?,
      categoryId: jsonSerialization['categoryId'] as int?,
      subcategoryId: jsonSerialization['subcategoryId'] as int?,
      itemCode: jsonSerialization['itemCode'] as String?,
      name: jsonSerialization['name'] as String,
      price: (jsonSerialization['price'] as num).toDouble(),
      imageUrl: jsonSerialization['imageUrl'] as String?,
      station: jsonSerialization['station'] as String?,
      type: jsonSerialization['type'] as String?,
      isAvailable: jsonSerialization['isAvailable'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['isAvailable']),
      allowPriceEdit: jsonSerialization['allowPriceEdit'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['allowPriceEdit']),
      isDeleted: jsonSerialization['isDeleted'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['isDeleted']),
      extras: jsonSerialization['extras'] == null
          ? null
          : _i3.Protocol().deserialize<List<_i2.ProductExtra>>(
              jsonSerialization['extras'],
            ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int? categoryId;

  int? subcategoryId;

  String? itemCode;

  String name;

  double price;

  String? imageUrl;

  String? station;

  String? type;

  bool isAvailable;

  bool allowPriceEdit;

  bool isDeleted;

  List<_i2.ProductExtra>? extras;

  /// Returns a shallow copy of this [Product]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Product copyWith({
    int? id,
    int? categoryId,
    int? subcategoryId,
    String? itemCode,
    String? name,
    double? price,
    String? imageUrl,
    String? station,
    String? type,
    bool? isAvailable,
    bool? allowPriceEdit,
    bool? isDeleted,
    List<_i2.ProductExtra>? extras,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Product',
      if (id != null) 'id': id,
      if (categoryId != null) 'categoryId': categoryId,
      if (subcategoryId != null) 'subcategoryId': subcategoryId,
      if (itemCode != null) 'itemCode': itemCode,
      'name': name,
      'price': price,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (station != null) 'station': station,
      if (type != null) 'type': type,
      'isAvailable': isAvailable,
      'allowPriceEdit': allowPriceEdit,
      'isDeleted': isDeleted,
      if (extras != null)
        'extras': extras?.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ProductImpl extends Product {
  _ProductImpl({
    int? id,
    int? categoryId,
    int? subcategoryId,
    String? itemCode,
    required String name,
    required double price,
    String? imageUrl,
    String? station,
    String? type,
    bool? isAvailable,
    bool? allowPriceEdit,
    bool? isDeleted,
    List<_i2.ProductExtra>? extras,
  }) : super._(
         id: id,
         categoryId: categoryId,
         subcategoryId: subcategoryId,
         itemCode: itemCode,
         name: name,
         price: price,
         imageUrl: imageUrl,
         station: station,
         type: type,
         isAvailable: isAvailable,
         allowPriceEdit: allowPriceEdit,
         isDeleted: isDeleted,
         extras: extras,
       );

  /// Returns a shallow copy of this [Product]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Product copyWith({
    Object? id = _Undefined,
    Object? categoryId = _Undefined,
    Object? subcategoryId = _Undefined,
    Object? itemCode = _Undefined,
    String? name,
    double? price,
    Object? imageUrl = _Undefined,
    Object? station = _Undefined,
    Object? type = _Undefined,
    bool? isAvailable,
    bool? allowPriceEdit,
    bool? isDeleted,
    Object? extras = _Undefined,
  }) {
    return Product(
      id: id is int? ? id : this.id,
      categoryId: categoryId is int? ? categoryId : this.categoryId,
      subcategoryId: subcategoryId is int? ? subcategoryId : this.subcategoryId,
      itemCode: itemCode is String? ? itemCode : this.itemCode,
      name: name ?? this.name,
      price: price ?? this.price,
      imageUrl: imageUrl is String? ? imageUrl : this.imageUrl,
      station: station is String? ? station : this.station,
      type: type is String? ? type : this.type,
      isAvailable: isAvailable ?? this.isAvailable,
      allowPriceEdit: allowPriceEdit ?? this.allowPriceEdit,
      isDeleted: isDeleted ?? this.isDeleted,
      extras: extras is List<_i2.ProductExtra>?
          ? extras
          : this.extras?.map((e0) => e0.copyWith()).toList(),
    );
  }
}
