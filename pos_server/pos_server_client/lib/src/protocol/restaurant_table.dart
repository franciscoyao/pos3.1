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

abstract class RestaurantTable implements _i1.SerializableModel {
  RestaurantTable._({
    this.id,
    required this.tableNumber,
    String? status,
    this.orderCode,
    int? guestCount,
    this.updatedAt,
  }) : status = status ?? 'Available',
       guestCount = guestCount ?? 0;

  factory RestaurantTable({
    int? id,
    required String tableNumber,
    String? status,
    String? orderCode,
    int? guestCount,
    DateTime? updatedAt,
  }) = _RestaurantTableImpl;

  factory RestaurantTable.fromJson(Map<String, dynamic> jsonSerialization) {
    return RestaurantTable(
      id: jsonSerialization['id'] as int?,
      tableNumber: jsonSerialization['tableNumber'] as String,
      status: jsonSerialization['status'] as String?,
      orderCode: jsonSerialization['orderCode'] as String?,
      guestCount: jsonSerialization['guestCount'] as int?,
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String tableNumber;

  String status;

  String? orderCode;

  int guestCount;

  DateTime? updatedAt;

  /// Returns a shallow copy of this [RestaurantTable]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  RestaurantTable copyWith({
    int? id,
    String? tableNumber,
    String? status,
    String? orderCode,
    int? guestCount,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RestaurantTable',
      if (id != null) 'id': id,
      'tableNumber': tableNumber,
      'status': status,
      if (orderCode != null) 'orderCode': orderCode,
      'guestCount': guestCount,
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RestaurantTableImpl extends RestaurantTable {
  _RestaurantTableImpl({
    int? id,
    required String tableNumber,
    String? status,
    String? orderCode,
    int? guestCount,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         tableNumber: tableNumber,
         status: status,
         orderCode: orderCode,
         guestCount: guestCount,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [RestaurantTable]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  RestaurantTable copyWith({
    Object? id = _Undefined,
    String? tableNumber,
    String? status,
    Object? orderCode = _Undefined,
    int? guestCount,
    Object? updatedAt = _Undefined,
  }) {
    return RestaurantTable(
      id: id is int? ? id : this.id,
      tableNumber: tableNumber ?? this.tableNumber,
      status: status ?? this.status,
      orderCode: orderCode is String? ? orderCode : this.orderCode,
      guestCount: guestCount ?? this.guestCount,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
    );
  }
}
