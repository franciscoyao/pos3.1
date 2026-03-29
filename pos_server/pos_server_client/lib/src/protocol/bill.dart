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

abstract class Bill implements _i1.SerializableModel {
  Bill._({
    this.id,
    required this.billNumber,
    this.orderType,
    this.tableNo,
    this.waiterName,
    this.paymentMethod,
    this.taxNumber,
    double? subtotal,
    double? taxAmount,
    double? serviceAmount,
    double? tipAmount,
    required this.total,
    this.createdAt,
  }) : subtotal = subtotal ?? 0.0,
       taxAmount = taxAmount ?? 0.0,
       serviceAmount = serviceAmount ?? 0.0,
       tipAmount = tipAmount ?? 0.0;

  factory Bill({
    int? id,
    required String billNumber,
    String? orderType,
    String? tableNo,
    String? waiterName,
    String? paymentMethod,
    String? taxNumber,
    double? subtotal,
    double? taxAmount,
    double? serviceAmount,
    double? tipAmount,
    required double total,
    DateTime? createdAt,
  }) = _BillImpl;

  factory Bill.fromJson(Map<String, dynamic> jsonSerialization) {
    return Bill(
      id: jsonSerialization['id'] as int?,
      billNumber: jsonSerialization['billNumber'] as String,
      orderType: jsonSerialization['orderType'] as String?,
      tableNo: jsonSerialization['tableNo'] as String?,
      waiterName: jsonSerialization['waiterName'] as String?,
      paymentMethod: jsonSerialization['paymentMethod'] as String?,
      taxNumber: jsonSerialization['taxNumber'] as String?,
      subtotal: (jsonSerialization['subtotal'] as num?)?.toDouble(),
      taxAmount: (jsonSerialization['taxAmount'] as num?)?.toDouble(),
      serviceAmount: (jsonSerialization['serviceAmount'] as num?)?.toDouble(),
      tipAmount: (jsonSerialization['tipAmount'] as num?)?.toDouble(),
      total: (jsonSerialization['total'] as num).toDouble(),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String billNumber;

  String? orderType;

  String? tableNo;

  String? waiterName;

  String? paymentMethod;

  String? taxNumber;

  double subtotal;

  double taxAmount;

  double serviceAmount;

  double tipAmount;

  double total;

  DateTime? createdAt;

  /// Returns a shallow copy of this [Bill]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Bill copyWith({
    int? id,
    String? billNumber,
    String? orderType,
    String? tableNo,
    String? waiterName,
    String? paymentMethod,
    String? taxNumber,
    double? subtotal,
    double? taxAmount,
    double? serviceAmount,
    double? tipAmount,
    double? total,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Bill',
      if (id != null) 'id': id,
      'billNumber': billNumber,
      if (orderType != null) 'orderType': orderType,
      if (tableNo != null) 'tableNo': tableNo,
      if (waiterName != null) 'waiterName': waiterName,
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
      if (taxNumber != null) 'taxNumber': taxNumber,
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'serviceAmount': serviceAmount,
      'tipAmount': tipAmount,
      'total': total,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _BillImpl extends Bill {
  _BillImpl({
    int? id,
    required String billNumber,
    String? orderType,
    String? tableNo,
    String? waiterName,
    String? paymentMethod,
    String? taxNumber,
    double? subtotal,
    double? taxAmount,
    double? serviceAmount,
    double? tipAmount,
    required double total,
    DateTime? createdAt,
  }) : super._(
         id: id,
         billNumber: billNumber,
         orderType: orderType,
         tableNo: tableNo,
         waiterName: waiterName,
         paymentMethod: paymentMethod,
         taxNumber: taxNumber,
         subtotal: subtotal,
         taxAmount: taxAmount,
         serviceAmount: serviceAmount,
         tipAmount: tipAmount,
         total: total,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Bill]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Bill copyWith({
    Object? id = _Undefined,
    String? billNumber,
    Object? orderType = _Undefined,
    Object? tableNo = _Undefined,
    Object? waiterName = _Undefined,
    Object? paymentMethod = _Undefined,
    Object? taxNumber = _Undefined,
    double? subtotal,
    double? taxAmount,
    double? serviceAmount,
    double? tipAmount,
    double? total,
    Object? createdAt = _Undefined,
  }) {
    return Bill(
      id: id is int? ? id : this.id,
      billNumber: billNumber ?? this.billNumber,
      orderType: orderType is String? ? orderType : this.orderType,
      tableNo: tableNo is String? ? tableNo : this.tableNo,
      waiterName: waiterName is String? ? waiterName : this.waiterName,
      paymentMethod: paymentMethod is String?
          ? paymentMethod
          : this.paymentMethod,
      taxNumber: taxNumber is String? ? taxNumber : this.taxNumber,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      serviceAmount: serviceAmount ?? this.serviceAmount,
      tipAmount: tipAmount ?? this.tipAmount,
      total: total ?? this.total,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
    );
  }
}
