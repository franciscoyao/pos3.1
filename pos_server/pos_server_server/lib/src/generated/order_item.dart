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

abstract class OrderItem
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  OrderItem._({
    this.id,
    required this.orderId,
    required this.productId,
    this.productName,
    this.productStation,
    required this.quantity,
    required this.price,
    double? totalPrice,
    this.notes,
    String? extras,
    this.billingTableNo,
  }) : totalPrice = totalPrice ?? 0.0,
       extras = extras ?? '[]';

  factory OrderItem({
    int? id,
    required int orderId,
    required int productId,
    String? productName,
    String? productStation,
    required int quantity,
    required double price,
    double? totalPrice,
    String? notes,
    String? extras,
    String? billingTableNo,
  }) = _OrderItemImpl;

  factory OrderItem.fromJson(Map<String, dynamic> jsonSerialization) {
    return OrderItem(
      id: jsonSerialization['id'] as int?,
      orderId: jsonSerialization['orderId'] as int,
      productId: jsonSerialization['productId'] as int,
      productName: jsonSerialization['productName'] as String?,
      productStation: jsonSerialization['productStation'] as String?,
      quantity: jsonSerialization['quantity'] as int,
      price: (jsonSerialization['price'] as num).toDouble(),
      totalPrice: (jsonSerialization['totalPrice'] as num?)?.toDouble(),
      notes: jsonSerialization['notes'] as String?,
      extras: jsonSerialization['extras'] as String?,
      billingTableNo: jsonSerialization['billingTableNo'] as String?,
    );
  }

  static final t = OrderItemTable();

  static const db = OrderItemRepository._();

  @override
  int? id;

  int orderId;

  int productId;

  String? productName;

  String? productStation;

  int quantity;

  double price;

  double totalPrice;

  String? notes;

  String? extras;

  String? billingTableNo;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [OrderItem]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  OrderItem copyWith({
    int? id,
    int? orderId,
    int? productId,
    String? productName,
    String? productStation,
    int? quantity,
    double? price,
    double? totalPrice,
    String? notes,
    String? extras,
    String? billingTableNo,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'OrderItem',
      if (id != null) 'id': id,
      'orderId': orderId,
      'productId': productId,
      if (productName != null) 'productName': productName,
      if (productStation != null) 'productStation': productStation,
      'quantity': quantity,
      'price': price,
      'totalPrice': totalPrice,
      if (notes != null) 'notes': notes,
      if (extras != null) 'extras': extras,
      if (billingTableNo != null) 'billingTableNo': billingTableNo,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'OrderItem',
      if (id != null) 'id': id,
      'orderId': orderId,
      'productId': productId,
      if (productName != null) 'productName': productName,
      if (productStation != null) 'productStation': productStation,
      'quantity': quantity,
      'price': price,
      'totalPrice': totalPrice,
      if (notes != null) 'notes': notes,
      if (extras != null) 'extras': extras,
      if (billingTableNo != null) 'billingTableNo': billingTableNo,
    };
  }

  static OrderItemInclude include() {
    return OrderItemInclude._();
  }

  static OrderItemIncludeList includeList({
    _i1.WhereExpressionBuilder<OrderItemTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<OrderItemTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<OrderItemTable>? orderByList,
    OrderItemInclude? include,
  }) {
    return OrderItemIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(OrderItem.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(OrderItem.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _OrderItemImpl extends OrderItem {
  _OrderItemImpl({
    int? id,
    required int orderId,
    required int productId,
    String? productName,
    String? productStation,
    required int quantity,
    required double price,
    double? totalPrice,
    String? notes,
    String? extras,
    String? billingTableNo,
  }) : super._(
         id: id,
         orderId: orderId,
         productId: productId,
         productName: productName,
         productStation: productStation,
         quantity: quantity,
         price: price,
         totalPrice: totalPrice,
         notes: notes,
         extras: extras,
         billingTableNo: billingTableNo,
       );

  /// Returns a shallow copy of this [OrderItem]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  OrderItem copyWith({
    Object? id = _Undefined,
    int? orderId,
    int? productId,
    Object? productName = _Undefined,
    Object? productStation = _Undefined,
    int? quantity,
    double? price,
    double? totalPrice,
    Object? notes = _Undefined,
    Object? extras = _Undefined,
    Object? billingTableNo = _Undefined,
  }) {
    return OrderItem(
      id: id is int? ? id : this.id,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      productName: productName is String? ? productName : this.productName,
      productStation: productStation is String?
          ? productStation
          : this.productStation,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      totalPrice: totalPrice ?? this.totalPrice,
      notes: notes is String? ? notes : this.notes,
      extras: extras is String? ? extras : this.extras,
      billingTableNo: billingTableNo is String?
          ? billingTableNo
          : this.billingTableNo,
    );
  }
}

class OrderItemUpdateTable extends _i1.UpdateTable<OrderItemTable> {
  OrderItemUpdateTable(super.table);

  _i1.ColumnValue<int, int> orderId(int value) => _i1.ColumnValue(
    table.orderId,
    value,
  );

  _i1.ColumnValue<int, int> productId(int value) => _i1.ColumnValue(
    table.productId,
    value,
  );

  _i1.ColumnValue<String, String> productName(String? value) => _i1.ColumnValue(
    table.productName,
    value,
  );

  _i1.ColumnValue<String, String> productStation(String? value) =>
      _i1.ColumnValue(
        table.productStation,
        value,
      );

  _i1.ColumnValue<int, int> quantity(int value) => _i1.ColumnValue(
    table.quantity,
    value,
  );

  _i1.ColumnValue<double, double> price(double value) => _i1.ColumnValue(
    table.price,
    value,
  );

  _i1.ColumnValue<double, double> totalPrice(double value) => _i1.ColumnValue(
    table.totalPrice,
    value,
  );

  _i1.ColumnValue<String, String> notes(String? value) => _i1.ColumnValue(
    table.notes,
    value,
  );

  _i1.ColumnValue<String, String> extras(String? value) => _i1.ColumnValue(
    table.extras,
    value,
  );

  _i1.ColumnValue<String, String> billingTableNo(String? value) =>
      _i1.ColumnValue(
        table.billingTableNo,
        value,
      );
}

class OrderItemTable extends _i1.Table<int?> {
  OrderItemTable({super.tableRelation}) : super(tableName: 'order_items') {
    updateTable = OrderItemUpdateTable(this);
    orderId = _i1.ColumnInt(
      'orderId',
      this,
    );
    productId = _i1.ColumnInt(
      'productId',
      this,
    );
    productName = _i1.ColumnString(
      'productName',
      this,
    );
    productStation = _i1.ColumnString(
      'productStation',
      this,
    );
    quantity = _i1.ColumnInt(
      'quantity',
      this,
    );
    price = _i1.ColumnDouble(
      'price',
      this,
    );
    totalPrice = _i1.ColumnDouble(
      'totalPrice',
      this,
      hasDefault: true,
    );
    notes = _i1.ColumnString(
      'notes',
      this,
    );
    extras = _i1.ColumnString(
      'extras',
      this,
      hasDefault: true,
    );
    billingTableNo = _i1.ColumnString(
      'billingTableNo',
      this,
    );
  }

  late final OrderItemUpdateTable updateTable;

  late final _i1.ColumnInt orderId;

  late final _i1.ColumnInt productId;

  late final _i1.ColumnString productName;

  late final _i1.ColumnString productStation;

  late final _i1.ColumnInt quantity;

  late final _i1.ColumnDouble price;

  late final _i1.ColumnDouble totalPrice;

  late final _i1.ColumnString notes;

  late final _i1.ColumnString extras;

  late final _i1.ColumnString billingTableNo;

  @override
  List<_i1.Column> get columns => [
    id,
    orderId,
    productId,
    productName,
    productStation,
    quantity,
    price,
    totalPrice,
    notes,
    extras,
    billingTableNo,
  ];
}

class OrderItemInclude extends _i1.IncludeObject {
  OrderItemInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => OrderItem.t;
}

class OrderItemIncludeList extends _i1.IncludeList {
  OrderItemIncludeList._({
    _i1.WhereExpressionBuilder<OrderItemTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(OrderItem.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => OrderItem.t;
}

class OrderItemRepository {
  const OrderItemRepository._();

  /// Returns a list of [OrderItem]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<OrderItem>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<OrderItemTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<OrderItemTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<OrderItemTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<OrderItem>(
      where: where?.call(OrderItem.t),
      orderBy: orderBy?.call(OrderItem.t),
      orderByList: orderByList?.call(OrderItem.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [OrderItem] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<OrderItem?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<OrderItemTable>? where,
    int? offset,
    _i1.OrderByBuilder<OrderItemTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<OrderItemTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<OrderItem>(
      where: where?.call(OrderItem.t),
      orderBy: orderBy?.call(OrderItem.t),
      orderByList: orderByList?.call(OrderItem.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [OrderItem] by its [id] or null if no such row exists.
  Future<OrderItem?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<OrderItem>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [OrderItem]s in the list and returns the inserted rows.
  ///
  /// The returned [OrderItem]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<OrderItem>> insert(
    _i1.DatabaseSession session,
    List<OrderItem> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<OrderItem>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [OrderItem] and returns the inserted row.
  ///
  /// The returned [OrderItem] will have its `id` field set.
  Future<OrderItem> insertRow(
    _i1.DatabaseSession session,
    OrderItem row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<OrderItem>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [OrderItem]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<OrderItem>> update(
    _i1.DatabaseSession session,
    List<OrderItem> rows, {
    _i1.ColumnSelections<OrderItemTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<OrderItem>(
      rows,
      columns: columns?.call(OrderItem.t),
      transaction: transaction,
    );
  }

  /// Updates a single [OrderItem]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<OrderItem> updateRow(
    _i1.DatabaseSession session,
    OrderItem row, {
    _i1.ColumnSelections<OrderItemTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<OrderItem>(
      row,
      columns: columns?.call(OrderItem.t),
      transaction: transaction,
    );
  }

  /// Updates a single [OrderItem] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<OrderItem?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<OrderItemUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<OrderItem>(
      id,
      columnValues: columnValues(OrderItem.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [OrderItem]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<OrderItem>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<OrderItemUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<OrderItemTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<OrderItemTable>? orderBy,
    _i1.OrderByListBuilder<OrderItemTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<OrderItem>(
      columnValues: columnValues(OrderItem.t.updateTable),
      where: where(OrderItem.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(OrderItem.t),
      orderByList: orderByList?.call(OrderItem.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [OrderItem]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<OrderItem>> delete(
    _i1.DatabaseSession session,
    List<OrderItem> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<OrderItem>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [OrderItem].
  Future<OrderItem> deleteRow(
    _i1.DatabaseSession session,
    OrderItem row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<OrderItem>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<OrderItem>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<OrderItemTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<OrderItem>(
      where: where(OrderItem.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<OrderItemTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<OrderItem>(
      where: where?.call(OrderItem.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [OrderItem] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<OrderItemTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<OrderItem>(
      where: where(OrderItem.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
