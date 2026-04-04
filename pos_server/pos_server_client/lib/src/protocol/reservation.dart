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

abstract class Reservation implements _i1.SerializableModel {
  Reservation._({
    this.id,
    required this.tableNumber,
    required this.customerName,
    this.customerPhone,
    required this.reservationTime,
    required this.guestCount,
    String? status,
    this.notes,
    this.email,
    required this.createdAt,
    this.updatedAt,
  }) : status = status ?? 'Pending';

  factory Reservation({
    int? id,
    required String tableNumber,
    required String customerName,
    String? customerPhone,
    required DateTime reservationTime,
    required int guestCount,
    String? status,
    String? notes,
    String? email,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _ReservationImpl;

  factory Reservation.fromJson(Map<String, dynamic> jsonSerialization) {
    return Reservation(
      id: jsonSerialization['id'] as int?,
      tableNumber: jsonSerialization['tableNumber'] as String,
      customerName: jsonSerialization['customerName'] as String,
      customerPhone: jsonSerialization['customerPhone'] as String?,
      reservationTime: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['reservationTime'],
      ),
      guestCount: jsonSerialization['guestCount'] as int,
      status: jsonSerialization['status'] as String?,
      notes: jsonSerialization['notes'] as String?,
      email: jsonSerialization['email'] as String?,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
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

  String customerName;

  String? customerPhone;

  DateTime reservationTime;

  int guestCount;

  String status;

  String? notes;

  String? email;

  DateTime createdAt;

  DateTime? updatedAt;

  /// Returns a shallow copy of this [Reservation]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Reservation copyWith({
    int? id,
    String? tableNumber,
    String? customerName,
    String? customerPhone,
    DateTime? reservationTime,
    int? guestCount,
    String? status,
    String? notes,
    String? email,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Reservation',
      if (id != null) 'id': id,
      'tableNumber': tableNumber,
      'customerName': customerName,
      if (customerPhone != null) 'customerPhone': customerPhone,
      'reservationTime': reservationTime.toJson(),
      'guestCount': guestCount,
      'status': status,
      if (notes != null) 'notes': notes,
      if (email != null) 'email': email,
      'createdAt': createdAt.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ReservationImpl extends Reservation {
  _ReservationImpl({
    int? id,
    required String tableNumber,
    required String customerName,
    String? customerPhone,
    required DateTime reservationTime,
    required int guestCount,
    String? status,
    String? notes,
    String? email,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         tableNumber: tableNumber,
         customerName: customerName,
         customerPhone: customerPhone,
         reservationTime: reservationTime,
         guestCount: guestCount,
         status: status,
         notes: notes,
         email: email,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [Reservation]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Reservation copyWith({
    Object? id = _Undefined,
    String? tableNumber,
    String? customerName,
    Object? customerPhone = _Undefined,
    DateTime? reservationTime,
    int? guestCount,
    String? status,
    Object? notes = _Undefined,
    Object? email = _Undefined,
    DateTime? createdAt,
    Object? updatedAt = _Undefined,
  }) {
    return Reservation(
      id: id is int? ? id : this.id,
      tableNumber: tableNumber ?? this.tableNumber,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone is String?
          ? customerPhone
          : this.customerPhone,
      reservationTime: reservationTime ?? this.reservationTime,
      guestCount: guestCount ?? this.guestCount,
      status: status ?? this.status,
      notes: notes is String? ? notes : this.notes,
      email: email is String? ? email : this.email,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
    );
  }
}
