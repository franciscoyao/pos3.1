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

abstract class PosUser implements _i1.SerializableModel {
  PosUser._({
    this.id,
    this.fullName,
    required this.username,
    this.pin,
    required this.role,
    String? status,
    bool? isDefault,
    this.createdAt,
  }) : status = status ?? 'Active',
       isDefault = isDefault ?? false;

  factory PosUser({
    int? id,
    String? fullName,
    required String username,
    String? pin,
    required String role,
    String? status,
    bool? isDefault,
    DateTime? createdAt,
  }) = _PosUserImpl;

  factory PosUser.fromJson(Map<String, dynamic> jsonSerialization) {
    return PosUser(
      id: jsonSerialization['id'] as int?,
      fullName: jsonSerialization['fullName'] as String?,
      username: jsonSerialization['username'] as String,
      pin: jsonSerialization['pin'] as String?,
      role: jsonSerialization['role'] as String,
      status: jsonSerialization['status'] as String?,
      isDefault: jsonSerialization['isDefault'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['isDefault']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String? fullName;

  String username;

  String? pin;

  String role;

  String status;

  bool isDefault;

  DateTime? createdAt;

  /// Returns a shallow copy of this [PosUser]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PosUser copyWith({
    int? id,
    String? fullName,
    String? username,
    String? pin,
    String? role,
    String? status,
    bool? isDefault,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PosUser',
      if (id != null) 'id': id,
      if (fullName != null) 'fullName': fullName,
      'username': username,
      if (pin != null) 'pin': pin,
      'role': role,
      'status': status,
      'isDefault': isDefault,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PosUserImpl extends PosUser {
  _PosUserImpl({
    int? id,
    String? fullName,
    required String username,
    String? pin,
    required String role,
    String? status,
    bool? isDefault,
    DateTime? createdAt,
  }) : super._(
         id: id,
         fullName: fullName,
         username: username,
         pin: pin,
         role: role,
         status: status,
         isDefault: isDefault,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [PosUser]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PosUser copyWith({
    Object? id = _Undefined,
    Object? fullName = _Undefined,
    String? username,
    Object? pin = _Undefined,
    String? role,
    String? status,
    bool? isDefault,
    Object? createdAt = _Undefined,
  }) {
    return PosUser(
      id: id is int? ? id : this.id,
      fullName: fullName is String? ? fullName : this.fullName,
      username: username ?? this.username,
      pin: pin is String? ? pin : this.pin,
      role: role ?? this.role,
      status: status ?? this.status,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
    );
  }
}
