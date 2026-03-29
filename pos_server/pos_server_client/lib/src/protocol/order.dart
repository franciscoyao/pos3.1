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
import 'order_item.dart' as _i2;
import 'package:pos_server_client/src/protocol/protocol.dart' as _i3;

abstract class PosOrder implements _i1.SerializableModel {
  PosOrder._({
    this.id,
    this.billId,
    this.orderCode,
    this.orderType,
    this.tableNo,
    String? status,
    this.waiterName,
    double? subtotal,
    double? taxAmount,
    double? serviceAmount,
    double? tipAmount,
    required this.total,
    this.createdAt,
    this.updatedAt,
    this.items,
  }) : status = status ?? 'Pending',
       subtotal = subtotal ?? 0.0,
       taxAmount = taxAmount ?? 0.0,
       serviceAmount = serviceAmount ?? 0.0,
       tipAmount = tipAmount ?? 0.0;

  factory PosOrder({
    int? id,
    int? billId,
    String? orderCode,
    String? orderType,
    String? tableNo,
    String? status,
    String? waiterName,
    double? subtotal,
    double? taxAmount,
    double? serviceAmount,
    double? tipAmount,
    required double total,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<_i2.OrderItem>? items,
  }) = _PosOrderImpl;

  factory PosOrder.fromJson(Map<String, dynamic> jsonSerialization) {
    return PosOrder(
      id: jsonSerialization['id'] as int?,
      billId: jsonSerialization['billId'] as int?,
      orderCode: jsonSerialization['orderCode'] as String?,
      orderType: jsonSerialization['orderType'] as String?,
      tableNo: jsonSerialization['tableNo'] as String?,
      status: jsonSerialization['status'] as String?,
      waiterName: jsonSerialization['waiterName'] as String?,
      subtotal: (jsonSerialization['subtotal'] as num?)?.toDouble(),
      taxAmount: (jsonSerialization['taxAmount'] as num?)?.toDouble(),
      serviceAmount: (jsonSerialization['serviceAmount'] as num?)?.toDouble(),
      tipAmount: (jsonSerialization['tipAmount'] as num?)?.toDouble(),
      total: (jsonSerialization['total'] as num).toDouble(),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      items: jsonSerialization['items'] == null
          ? null
          : _i3.Protocol().deserialize<List<_i2.OrderItem>>(
              jsonSerialization['items'],
            ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int? billId;

  String? orderCode;

  String? orderType;

  String? tableNo;

  String status;

  String? waiterName;

  double subtotal;

  double taxAmount;

  double serviceAmount;

  double tipAmount;

  double total;

  DateTime? createdAt;

  DateTime? updatedAt;

  List<_i2.OrderItem>? items;

  /// Returns a shallow copy of this [PosOrder]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PosOrder copyWith({
    int? id,
    int? billId,
    String? orderCode,
    String? orderType,
    String? tableNo,
    String? status,
    String? waiterName,
    double? subtotal,
    double? taxAmount,
    double? serviceAmount,
    double? tipAmount,
    double? total,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<_i2.OrderItem>? items,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PosOrder',
      if (id != null) 'id': id,
      if (billId != null) 'billId': billId,
      if (orderCode != null) 'orderCode': orderCode,
      if (orderType != null) 'orderType': orderType,
      if (tableNo != null) 'tableNo': tableNo,
      'status': status,
      if (waiterName != null) 'waiterName': waiterName,
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'serviceAmount': serviceAmount,
      'tipAmount': tipAmount,
      'total': total,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
      if (items != null) 'items': items?.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PosOrderImpl extends PosOrder {
  _PosOrderImpl({
    int? id,
    int? billId,
    String? orderCode,
    String? orderType,
    String? tableNo,
    String? status,
    String? waiterName,
    double? subtotal,
    double? taxAmount,
    double? serviceAmount,
    double? tipAmount,
    required double total,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<_i2.OrderItem>? items,
  }) : super._(
         id: id,
         billId: billId,
         orderCode: orderCode,
         orderType: orderType,
         tableNo: tableNo,
         status: status,
         waiterName: waiterName,
         subtotal: subtotal,
         taxAmount: taxAmount,
         serviceAmount: serviceAmount,
         tipAmount: tipAmount,
         total: total,
         createdAt: createdAt,
         updatedAt: updatedAt,
         items: items,
       );

  /// Returns a shallow copy of this [PosOrder]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PosOrder copyWith({
    Object? id = _Undefined,
    Object? billId = _Undefined,
    Object? orderCode = _Undefined,
    Object? orderType = _Undefined,
    Object? tableNo = _Undefined,
    String? status,
    Object? waiterName = _Undefined,
    double? subtotal,
    double? taxAmount,
    double? serviceAmount,
    double? tipAmount,
    double? total,
    Object? createdAt = _Undefined,
    Object? updatedAt = _Undefined,
    Object? items = _Undefined,
  }) {
    return PosOrder(
      id: id is int? ? id : this.id,
      billId: billId is int? ? billId : this.billId,
      orderCode: orderCode is String? ? orderCode : this.orderCode,
      orderType: orderType is String? ? orderType : this.orderType,
      tableNo: tableNo is String? ? tableNo : this.tableNo,
      status: status ?? this.status,
      waiterName: waiterName is String? ? waiterName : this.waiterName,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      serviceAmount: serviceAmount ?? this.serviceAmount,
      tipAmount: tipAmount ?? this.tipAmount,
      total: total ?? this.total,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
      items: items is List<_i2.OrderItem>?
          ? items
          : this.items?.map((e0) => e0.copyWith()).toList(),
    );
  }
}
