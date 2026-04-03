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

abstract class BillItem
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  BillItem._({
    this.id,
    required this.billId,
    this.productName,
    required this.quantity,
    required this.price,
    double? totalPrice,
  }) : totalPrice = totalPrice ?? 0.0;

  factory BillItem({
    int? id,
    required int billId,
    String? productName,
    required int quantity,
    required double price,
    double? totalPrice,
  }) = _BillItemImpl;

  factory BillItem.fromJson(Map<String, dynamic> jsonSerialization) {
    return BillItem(
      id: jsonSerialization['id'] as int?,
      billId: jsonSerialization['billId'] as int,
      productName: jsonSerialization['productName'] as String?,
      quantity: jsonSerialization['quantity'] as int,
      price: (jsonSerialization['price'] as num).toDouble(),
      totalPrice: (jsonSerialization['totalPrice'] as num?)?.toDouble(),
    );
  }

  static final t = BillItemTable();

  static const db = BillItemRepository._();

  @override
  int? id;

  int billId;

  String? productName;

  int quantity;

  double price;

  double totalPrice;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [BillItem]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  BillItem copyWith({
    int? id,
    int? billId,
    String? productName,
    int? quantity,
    double? price,
    double? totalPrice,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'BillItem',
      if (id != null) 'id': id,
      'billId': billId,
      if (productName != null) 'productName': productName,
      'quantity': quantity,
      'price': price,
      'totalPrice': totalPrice,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'BillItem',
      if (id != null) 'id': id,
      'billId': billId,
      if (productName != null) 'productName': productName,
      'quantity': quantity,
      'price': price,
      'totalPrice': totalPrice,
    };
  }

  static BillItemInclude include() {
    return BillItemInclude._();
  }

  static BillItemIncludeList includeList({
    _i1.WhereExpressionBuilder<BillItemTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<BillItemTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<BillItemTable>? orderByList,
    BillItemInclude? include,
  }) {
    return BillItemIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(BillItem.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(BillItem.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _BillItemImpl extends BillItem {
  _BillItemImpl({
    int? id,
    required int billId,
    String? productName,
    required int quantity,
    required double price,
    double? totalPrice,
  }) : super._(
         id: id,
         billId: billId,
         productName: productName,
         quantity: quantity,
         price: price,
         totalPrice: totalPrice,
       );

  /// Returns a shallow copy of this [BillItem]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  BillItem copyWith({
    Object? id = _Undefined,
    int? billId,
    Object? productName = _Undefined,
    int? quantity,
    double? price,
    double? totalPrice,
  }) {
    return BillItem(
      id: id is int? ? id : this.id,
      billId: billId ?? this.billId,
      productName: productName is String? ? productName : this.productName,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}

class BillItemUpdateTable extends _i1.UpdateTable<BillItemTable> {
  BillItemUpdateTable(super.table);

  _i1.ColumnValue<int, int> billId(int value) => _i1.ColumnValue(
    table.billId,
    value,
  );

  _i1.ColumnValue<String, String> productName(String? value) => _i1.ColumnValue(
    table.productName,
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
}

class BillItemTable extends _i1.Table<int?> {
  BillItemTable({super.tableRelation}) : super(tableName: 'bill_items') {
    updateTable = BillItemUpdateTable(this);
    billId = _i1.ColumnInt(
      'billId',
      this,
    );
    productName = _i1.ColumnString(
      'productName',
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
  }

  late final BillItemUpdateTable updateTable;

  late final _i1.ColumnInt billId;

  late final _i1.ColumnString productName;

  late final _i1.ColumnInt quantity;

  late final _i1.ColumnDouble price;

  late final _i1.ColumnDouble totalPrice;

  @override
  List<_i1.Column> get columns => [
    id,
    billId,
    productName,
    quantity,
    price,
    totalPrice,
  ];
}

class BillItemInclude extends _i1.IncludeObject {
  BillItemInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => BillItem.t;
}

class BillItemIncludeList extends _i1.IncludeList {
  BillItemIncludeList._({
    _i1.WhereExpressionBuilder<BillItemTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(BillItem.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => BillItem.t;
}

class BillItemRepository {
  const BillItemRepository._();

  /// Returns a list of [BillItem]s matching the given query parameters.
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
  Future<List<BillItem>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<BillItemTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<BillItemTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<BillItemTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<BillItem>(
      where: where?.call(BillItem.t),
      orderBy: orderBy?.call(BillItem.t),
      orderByList: orderByList?.call(BillItem.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [BillItem] matching the given query parameters.
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
  Future<BillItem?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<BillItemTable>? where,
    int? offset,
    _i1.OrderByBuilder<BillItemTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<BillItemTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<BillItem>(
      where: where?.call(BillItem.t),
      orderBy: orderBy?.call(BillItem.t),
      orderByList: orderByList?.call(BillItem.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [BillItem] by its [id] or null if no such row exists.
  Future<BillItem?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<BillItem>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [BillItem]s in the list and returns the inserted rows.
  ///
  /// The returned [BillItem]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<BillItem>> insert(
    _i1.DatabaseSession session,
    List<BillItem> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<BillItem>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [BillItem] and returns the inserted row.
  ///
  /// The returned [BillItem] will have its `id` field set.
  Future<BillItem> insertRow(
    _i1.DatabaseSession session,
    BillItem row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<BillItem>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [BillItem]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<BillItem>> update(
    _i1.DatabaseSession session,
    List<BillItem> rows, {
    _i1.ColumnSelections<BillItemTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<BillItem>(
      rows,
      columns: columns?.call(BillItem.t),
      transaction: transaction,
    );
  }

  /// Updates a single [BillItem]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<BillItem> updateRow(
    _i1.DatabaseSession session,
    BillItem row, {
    _i1.ColumnSelections<BillItemTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<BillItem>(
      row,
      columns: columns?.call(BillItem.t),
      transaction: transaction,
    );
  }

  /// Updates a single [BillItem] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<BillItem?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<BillItemUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<BillItem>(
      id,
      columnValues: columnValues(BillItem.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [BillItem]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<BillItem>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<BillItemUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<BillItemTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<BillItemTable>? orderBy,
    _i1.OrderByListBuilder<BillItemTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<BillItem>(
      columnValues: columnValues(BillItem.t.updateTable),
      where: where(BillItem.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(BillItem.t),
      orderByList: orderByList?.call(BillItem.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [BillItem]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<BillItem>> delete(
    _i1.DatabaseSession session,
    List<BillItem> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<BillItem>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [BillItem].
  Future<BillItem> deleteRow(
    _i1.DatabaseSession session,
    BillItem row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<BillItem>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<BillItem>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<BillItemTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<BillItem>(
      where: where(BillItem.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<BillItemTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<BillItem>(
      where: where?.call(BillItem.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [BillItem] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<BillItemTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<BillItem>(
      where: where(BillItem.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
