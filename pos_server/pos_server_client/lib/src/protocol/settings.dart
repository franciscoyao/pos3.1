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

abstract class Settings implements _i1.SerializableModel {
  Settings._({
    this.id,
    required this.taxRate,
    required this.serviceCharge,
    required this.currencySymbol,
    required this.orderDelayThreshold,
    this.updatedAt,
  });

  factory Settings({
    int? id,
    required double taxRate,
    required double serviceCharge,
    required String currencySymbol,
    required int orderDelayThreshold,
    DateTime? updatedAt,
  }) = _SettingsImpl;

  factory Settings.fromJson(Map<String, dynamic> jsonSerialization) {
    return Settings(
      id: jsonSerialization['id'] as int?,
      taxRate: (jsonSerialization['taxRate'] as num).toDouble(),
      serviceCharge: (jsonSerialization['serviceCharge'] as num).toDouble(),
      currencySymbol: jsonSerialization['currencySymbol'] as String,
      orderDelayThreshold: jsonSerialization['orderDelayThreshold'] as int,
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  double taxRate;

  double serviceCharge;

  String currencySymbol;

  int orderDelayThreshold;

  DateTime? updatedAt;

  /// Returns a shallow copy of this [Settings]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Settings copyWith({
    int? id,
    double? taxRate,
    double? serviceCharge,
    String? currencySymbol,
    int? orderDelayThreshold,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Settings',
      if (id != null) 'id': id,
      'taxRate': taxRate,
      'serviceCharge': serviceCharge,
      'currencySymbol': currencySymbol,
      'orderDelayThreshold': orderDelayThreshold,
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SettingsImpl extends Settings {
  _SettingsImpl({
    int? id,
    required double taxRate,
    required double serviceCharge,
    required String currencySymbol,
    required int orderDelayThreshold,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         taxRate: taxRate,
         serviceCharge: serviceCharge,
         currencySymbol: currencySymbol,
         orderDelayThreshold: orderDelayThreshold,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [Settings]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Settings copyWith({
    Object? id = _Undefined,
    double? taxRate,
    double? serviceCharge,
    String? currencySymbol,
    int? orderDelayThreshold,
    Object? updatedAt = _Undefined,
  }) {
    return Settings(
      id: id is int? ? id : this.id,
      taxRate: taxRate ?? this.taxRate,
      serviceCharge: serviceCharge ?? this.serviceCharge,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      orderDelayThreshold: orderDelayThreshold ?? this.orderDelayThreshold,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
    );
  }
}
