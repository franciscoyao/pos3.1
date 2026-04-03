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
import 'bill.dart' as _i2;
import 'bill_item.dart' as _i3;
import 'bill_with_items.dart' as _i4;
import 'category.dart' as _i5;
import 'checkout_item.dart' as _i6;
import 'greetings/greeting.dart' as _i7;
import 'order.dart' as _i8;
import 'order_item.dart' as _i9;
import 'pos_event.dart' as _i10;
import 'pos_user.dart' as _i11;
import 'product.dart' as _i12;
import 'product_extra.dart' as _i13;
import 'reservation.dart' as _i14;
import 'restaurant_table.dart' as _i15;
import 'settings.dart' as _i16;
import 'subcategory.dart' as _i17;
import 'package:pos_server_client/src/protocol/category.dart' as _i18;
import 'package:pos_server_client/src/protocol/checkout_item.dart' as _i19;
import 'package:pos_server_client/src/protocol/bill.dart' as _i20;
import 'package:pos_server_client/src/protocol/order.dart' as _i21;
import 'package:pos_server_client/src/protocol/order_item.dart' as _i22;
import 'package:pos_server_client/src/protocol/product.dart' as _i23;
import 'package:pos_server_client/src/protocol/reservation.dart' as _i24;
import 'package:pos_server_client/src/protocol/subcategory.dart' as _i25;
import 'package:pos_server_client/src/protocol/restaurant_table.dart' as _i26;
import 'package:pos_server_client/src/protocol/pos_user.dart' as _i27;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i28;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i29;
export 'bill.dart';
export 'bill_item.dart';
export 'bill_with_items.dart';
export 'category.dart';
export 'checkout_item.dart';
export 'greetings/greeting.dart';
export 'order.dart';
export 'order_item.dart';
export 'pos_event.dart';
export 'pos_user.dart';
export 'product.dart';
export 'product_extra.dart';
export 'reservation.dart';
export 'restaurant_table.dart';
export 'settings.dart';
export 'subcategory.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on FormatException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i2.Bill) {
      return _i2.Bill.fromJson(data) as T;
    }
    if (t == _i3.BillItem) {
      return _i3.BillItem.fromJson(data) as T;
    }
    if (t == _i4.BillWithItems) {
      return _i4.BillWithItems.fromJson(data) as T;
    }
    if (t == _i5.Category) {
      return _i5.Category.fromJson(data) as T;
    }
    if (t == _i6.CheckoutItem) {
      return _i6.CheckoutItem.fromJson(data) as T;
    }
    if (t == _i7.Greeting) {
      return _i7.Greeting.fromJson(data) as T;
    }
    if (t == _i8.PosOrder) {
      return _i8.PosOrder.fromJson(data) as T;
    }
    if (t == _i9.OrderItem) {
      return _i9.OrderItem.fromJson(data) as T;
    }
    if (t == _i10.PosEvent) {
      return _i10.PosEvent.fromJson(data) as T;
    }
    if (t == _i11.PosUser) {
      return _i11.PosUser.fromJson(data) as T;
    }
    if (t == _i12.Product) {
      return _i12.Product.fromJson(data) as T;
    }
    if (t == _i13.ProductExtra) {
      return _i13.ProductExtra.fromJson(data) as T;
    }
    if (t == _i14.Reservation) {
      return _i14.Reservation.fromJson(data) as T;
    }
    if (t == _i15.RestaurantTable) {
      return _i15.RestaurantTable.fromJson(data) as T;
    }
    if (t == _i16.Settings) {
      return _i16.Settings.fromJson(data) as T;
    }
    if (t == _i17.Subcategory) {
      return _i17.Subcategory.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.Bill?>()) {
      return (data != null ? _i2.Bill.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.BillItem?>()) {
      return (data != null ? _i3.BillItem.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.BillWithItems?>()) {
      return (data != null ? _i4.BillWithItems.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.Category?>()) {
      return (data != null ? _i5.Category.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.CheckoutItem?>()) {
      return (data != null ? _i6.CheckoutItem.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.Greeting?>()) {
      return (data != null ? _i7.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.PosOrder?>()) {
      return (data != null ? _i8.PosOrder.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.OrderItem?>()) {
      return (data != null ? _i9.OrderItem.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.PosEvent?>()) {
      return (data != null ? _i10.PosEvent.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.PosUser?>()) {
      return (data != null ? _i11.PosUser.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.Product?>()) {
      return (data != null ? _i12.Product.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.ProductExtra?>()) {
      return (data != null ? _i13.ProductExtra.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i14.Reservation?>()) {
      return (data != null ? _i14.Reservation.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i15.RestaurantTable?>()) {
      return (data != null ? _i15.RestaurantTable.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i16.Settings?>()) {
      return (data != null ? _i16.Settings.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i17.Subcategory?>()) {
      return (data != null ? _i17.Subcategory.fromJson(data) : null) as T;
    }
    if (t == List<_i3.BillItem>) {
      return (data as List).map((e) => deserialize<_i3.BillItem>(e)).toList()
          as T;
    }
    if (t == List<_i9.OrderItem>) {
      return (data as List).map((e) => deserialize<_i9.OrderItem>(e)).toList()
          as T;
    }
    if (t == _i1.getType<List<_i9.OrderItem>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i9.OrderItem>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_i13.ProductExtra>) {
      return (data as List)
              .map((e) => deserialize<_i13.ProductExtra>(e))
              .toList()
          as T;
    }
    if (t == _i1.getType<List<_i13.ProductExtra>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i13.ProductExtra>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_i18.Category>) {
      return (data as List).map((e) => deserialize<_i18.Category>(e)).toList()
          as T;
    }
    if (t == List<_i19.CheckoutItem>) {
      return (data as List)
              .map((e) => deserialize<_i19.CheckoutItem>(e))
              .toList()
          as T;
    }
    if (t == _i1.getType<List<_i19.CheckoutItem>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i19.CheckoutItem>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_i20.Bill>) {
      return (data as List).map((e) => deserialize<_i20.Bill>(e)).toList() as T;
    }
    if (t == List<_i21.PosOrder>) {
      return (data as List).map((e) => deserialize<_i21.PosOrder>(e)).toList()
          as T;
    }
    if (t == List<_i22.OrderItem>) {
      return (data as List).map((e) => deserialize<_i22.OrderItem>(e)).toList()
          as T;
    }
    if (t == List<Map<String, dynamic>>) {
      return (data as List)
              .map((e) => deserialize<Map<String, dynamic>>(e))
              .toList()
          as T;
    }
    if (t == Map<String, dynamic>) {
      return (data as Map).map(
            (k, v) => MapEntry(deserialize<String>(k), deserialize<dynamic>(v)),
          )
          as T;
    }
    if (t == List<_i23.Product>) {
      return (data as List).map((e) => deserialize<_i23.Product>(e)).toList()
          as T;
    }
    if (t == List<_i24.Reservation>) {
      return (data as List)
              .map((e) => deserialize<_i24.Reservation>(e))
              .toList()
          as T;
    }
    if (t == List<_i25.Subcategory>) {
      return (data as List)
              .map((e) => deserialize<_i25.Subcategory>(e))
              .toList()
          as T;
    }
    if (t == List<_i26.RestaurantTable>) {
      return (data as List)
              .map((e) => deserialize<_i26.RestaurantTable>(e))
              .toList()
          as T;
    }
    if (t == List<int>) {
      return (data as List).map((e) => deserialize<int>(e)).toList() as T;
    }
    if (t == List<_i27.PosUser>) {
      return (data as List).map((e) => deserialize<_i27.PosUser>(e)).toList()
          as T;
    }
    try {
      return _i28.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i29.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.Bill => 'Bill',
      _i3.BillItem => 'BillItem',
      _i4.BillWithItems => 'BillWithItems',
      _i5.Category => 'Category',
      _i6.CheckoutItem => 'CheckoutItem',
      _i7.Greeting => 'Greeting',
      _i8.PosOrder => 'PosOrder',
      _i9.OrderItem => 'OrderItem',
      _i10.PosEvent => 'PosEvent',
      _i11.PosUser => 'PosUser',
      _i12.Product => 'Product',
      _i13.ProductExtra => 'ProductExtra',
      _i14.Reservation => 'Reservation',
      _i15.RestaurantTable => 'RestaurantTable',
      _i16.Settings => 'Settings',
      _i17.Subcategory => 'Subcategory',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('pos_server.', '');
    }

    switch (data) {
      case _i2.Bill():
        return 'Bill';
      case _i3.BillItem():
        return 'BillItem';
      case _i4.BillWithItems():
        return 'BillWithItems';
      case _i5.Category():
        return 'Category';
      case _i6.CheckoutItem():
        return 'CheckoutItem';
      case _i7.Greeting():
        return 'Greeting';
      case _i8.PosOrder():
        return 'PosOrder';
      case _i9.OrderItem():
        return 'OrderItem';
      case _i10.PosEvent():
        return 'PosEvent';
      case _i11.PosUser():
        return 'PosUser';
      case _i12.Product():
        return 'Product';
      case _i13.ProductExtra():
        return 'ProductExtra';
      case _i14.Reservation():
        return 'Reservation';
      case _i15.RestaurantTable():
        return 'RestaurantTable';
      case _i16.Settings():
        return 'Settings';
      case _i17.Subcategory():
        return 'Subcategory';
    }
    className = _i28.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i29.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_core.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'Bill') {
      return deserialize<_i2.Bill>(data['data']);
    }
    if (dataClassName == 'BillItem') {
      return deserialize<_i3.BillItem>(data['data']);
    }
    if (dataClassName == 'BillWithItems') {
      return deserialize<_i4.BillWithItems>(data['data']);
    }
    if (dataClassName == 'Category') {
      return deserialize<_i5.Category>(data['data']);
    }
    if (dataClassName == 'CheckoutItem') {
      return deserialize<_i6.CheckoutItem>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i7.Greeting>(data['data']);
    }
    if (dataClassName == 'PosOrder') {
      return deserialize<_i8.PosOrder>(data['data']);
    }
    if (dataClassName == 'OrderItem') {
      return deserialize<_i9.OrderItem>(data['data']);
    }
    if (dataClassName == 'PosEvent') {
      return deserialize<_i10.PosEvent>(data['data']);
    }
    if (dataClassName == 'PosUser') {
      return deserialize<_i11.PosUser>(data['data']);
    }
    if (dataClassName == 'Product') {
      return deserialize<_i12.Product>(data['data']);
    }
    if (dataClassName == 'ProductExtra') {
      return deserialize<_i13.ProductExtra>(data['data']);
    }
    if (dataClassName == 'Reservation') {
      return deserialize<_i14.Reservation>(data['data']);
    }
    if (dataClassName == 'RestaurantTable') {
      return deserialize<_i15.RestaurantTable>(data['data']);
    }
    if (dataClassName == 'Settings') {
      return deserialize<_i16.Settings>(data['data']);
    }
    if (dataClassName == 'Subcategory') {
      return deserialize<_i17.Subcategory>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i28.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i29.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _i28.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i29.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
