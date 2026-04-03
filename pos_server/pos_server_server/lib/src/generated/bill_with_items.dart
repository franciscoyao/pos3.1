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
import 'package:serverpod/serverpod.dart' as _i1;
import 'bill.dart' as _i2;
import 'bill_item.dart' as _i3;
import 'package:pos_server_server/src/generated/protocol.dart' as _i4;

abstract class BillWithItems
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  BillWithItems._({
    required this.bill,
    required this.items,
  });

  factory BillWithItems({
    required _i2.Bill bill,
    required List<_i3.BillItem> items,
  }) = _BillWithItemsImpl;

  factory BillWithItems.fromJson(Map<String, dynamic> jsonSerialization) {
    return BillWithItems(
      bill: _i4.Protocol().deserialize<_i2.Bill>(jsonSerialization['bill']),
      items: _i4.Protocol().deserialize<List<_i3.BillItem>>(
        jsonSerialization['items'],
      ),
    );
  }

  _i2.Bill bill;

  List<_i3.BillItem> items;

  /// Returns a shallow copy of this [BillWithItems]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  BillWithItems copyWith({
    _i2.Bill? bill,
    List<_i3.BillItem>? items,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'BillWithItems',
      'bill': bill.toJson(),
      'items': items.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'BillWithItems',
      'bill': bill.toJsonForProtocol(),
      'items': items.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _BillWithItemsImpl extends BillWithItems {
  _BillWithItemsImpl({
    required _i2.Bill bill,
    required List<_i3.BillItem> items,
  }) : super._(
         bill: bill,
         items: items,
       );

  /// Returns a shallow copy of this [BillWithItems]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  BillWithItems copyWith({
    _i2.Bill? bill,
    List<_i3.BillItem>? items,
  }) {
    return BillWithItems(
      bill: bill ?? this.bill.copyWith(),
      items: items ?? this.items.map((e0) => e0.copyWith()).toList(),
    );
  }
}
