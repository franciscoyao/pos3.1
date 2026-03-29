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

/// Real-time broadcast event sent to all connected clients.
abstract class PosEvent implements _i1.SerializableModel {
  PosEvent._({
    required this.eventType,
    this.payload,
  });

  factory PosEvent({
    required String eventType,
    String? payload,
  }) = _PosEventImpl;

  factory PosEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return PosEvent(
      eventType: jsonSerialization['eventType'] as String,
      payload: jsonSerialization['payload'] as String?,
    );
  }

  String eventType;

  String? payload;

  /// Returns a shallow copy of this [PosEvent]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PosEvent copyWith({
    String? eventType,
    String? payload,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PosEvent',
      'eventType': eventType,
      if (payload != null) 'payload': payload,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PosEventImpl extends PosEvent {
  _PosEventImpl({
    required String eventType,
    String? payload,
  }) : super._(
         eventType: eventType,
         payload: payload,
       );

  /// Returns a shallow copy of this [PosEvent]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PosEvent copyWith({
    String? eventType,
    Object? payload = _Undefined,
  }) {
    return PosEvent(
      eventType: eventType ?? this.eventType,
      payload: payload is String? ? payload : this.payload,
    );
  }
}
