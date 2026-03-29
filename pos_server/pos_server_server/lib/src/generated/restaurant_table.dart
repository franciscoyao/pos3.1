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

abstract class RestaurantTable
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  RestaurantTable._({
    this.id,
    required this.tableNumber,
    String? status,
    this.orderCode,
    int? guestCount,
    this.updatedAt,
  }) : status = status ?? 'Available',
       guestCount = guestCount ?? 0;

  factory RestaurantTable({
    int? id,
    required String tableNumber,
    String? status,
    String? orderCode,
    int? guestCount,
    DateTime? updatedAt,
  }) = _RestaurantTableImpl;

  factory RestaurantTable.fromJson(Map<String, dynamic> jsonSerialization) {
    return RestaurantTable(
      id: jsonSerialization['id'] as int?,
      tableNumber: jsonSerialization['tableNumber'] as String,
      status: jsonSerialization['status'] as String?,
      orderCode: jsonSerialization['orderCode'] as String?,
      guestCount: jsonSerialization['guestCount'] as int?,
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = RestaurantTableTable();

  static const db = RestaurantTableRepository._();

  @override
  int? id;

  String tableNumber;

  String status;

  String? orderCode;

  int guestCount;

  DateTime? updatedAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [RestaurantTable]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  RestaurantTable copyWith({
    int? id,
    String? tableNumber,
    String? status,
    String? orderCode,
    int? guestCount,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RestaurantTable',
      if (id != null) 'id': id,
      'tableNumber': tableNumber,
      'status': status,
      if (orderCode != null) 'orderCode': orderCode,
      'guestCount': guestCount,
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RestaurantTable',
      if (id != null) 'id': id,
      'tableNumber': tableNumber,
      'status': status,
      if (orderCode != null) 'orderCode': orderCode,
      'guestCount': guestCount,
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  static RestaurantTableInclude include() {
    return RestaurantTableInclude._();
  }

  static RestaurantTableIncludeList includeList({
    _i1.WhereExpressionBuilder<RestaurantTableTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<RestaurantTableTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<RestaurantTableTable>? orderByList,
    RestaurantTableInclude? include,
  }) {
    return RestaurantTableIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RestaurantTable.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(RestaurantTable.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RestaurantTableImpl extends RestaurantTable {
  _RestaurantTableImpl({
    int? id,
    required String tableNumber,
    String? status,
    String? orderCode,
    int? guestCount,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         tableNumber: tableNumber,
         status: status,
         orderCode: orderCode,
         guestCount: guestCount,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [RestaurantTable]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  RestaurantTable copyWith({
    Object? id = _Undefined,
    String? tableNumber,
    String? status,
    Object? orderCode = _Undefined,
    int? guestCount,
    Object? updatedAt = _Undefined,
  }) {
    return RestaurantTable(
      id: id is int? ? id : this.id,
      tableNumber: tableNumber ?? this.tableNumber,
      status: status ?? this.status,
      orderCode: orderCode is String? ? orderCode : this.orderCode,
      guestCount: guestCount ?? this.guestCount,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
    );
  }
}

class RestaurantTableUpdateTable extends _i1.UpdateTable<RestaurantTableTable> {
  RestaurantTableUpdateTable(super.table);

  _i1.ColumnValue<String, String> tableNumber(String value) => _i1.ColumnValue(
    table.tableNumber,
    value,
  );

  _i1.ColumnValue<String, String> status(String value) => _i1.ColumnValue(
    table.status,
    value,
  );

  _i1.ColumnValue<String, String> orderCode(String? value) => _i1.ColumnValue(
    table.orderCode,
    value,
  );

  _i1.ColumnValue<int, int> guestCount(int value) => _i1.ColumnValue(
    table.guestCount,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> updatedAt(DateTime? value) =>
      _i1.ColumnValue(
        table.updatedAt,
        value,
      );
}

class RestaurantTableTable extends _i1.Table<int?> {
  RestaurantTableTable({super.tableRelation})
    : super(tableName: 'restaurant_tables') {
    updateTable = RestaurantTableUpdateTable(this);
    tableNumber = _i1.ColumnString(
      'tableNumber',
      this,
    );
    status = _i1.ColumnString(
      'status',
      this,
      hasDefault: true,
    );
    orderCode = _i1.ColumnString(
      'orderCode',
      this,
    );
    guestCount = _i1.ColumnInt(
      'guestCount',
      this,
      hasDefault: true,
    );
    updatedAt = _i1.ColumnDateTime(
      'updatedAt',
      this,
    );
  }

  late final RestaurantTableUpdateTable updateTable;

  late final _i1.ColumnString tableNumber;

  late final _i1.ColumnString status;

  late final _i1.ColumnString orderCode;

  late final _i1.ColumnInt guestCount;

  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    tableNumber,
    status,
    orderCode,
    guestCount,
    updatedAt,
  ];
}

class RestaurantTableInclude extends _i1.IncludeObject {
  RestaurantTableInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => RestaurantTable.t;
}

class RestaurantTableIncludeList extends _i1.IncludeList {
  RestaurantTableIncludeList._({
    _i1.WhereExpressionBuilder<RestaurantTableTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(RestaurantTable.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => RestaurantTable.t;
}

class RestaurantTableRepository {
  const RestaurantTableRepository._();

  /// Returns a list of [RestaurantTable]s matching the given query parameters.
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
  Future<List<RestaurantTable>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<RestaurantTableTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<RestaurantTableTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<RestaurantTableTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<RestaurantTable>(
      where: where?.call(RestaurantTable.t),
      orderBy: orderBy?.call(RestaurantTable.t),
      orderByList: orderByList?.call(RestaurantTable.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [RestaurantTable] matching the given query parameters.
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
  Future<RestaurantTable?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<RestaurantTableTable>? where,
    int? offset,
    _i1.OrderByBuilder<RestaurantTableTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<RestaurantTableTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<RestaurantTable>(
      where: where?.call(RestaurantTable.t),
      orderBy: orderBy?.call(RestaurantTable.t),
      orderByList: orderByList?.call(RestaurantTable.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [RestaurantTable] by its [id] or null if no such row exists.
  Future<RestaurantTable?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<RestaurantTable>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [RestaurantTable]s in the list and returns the inserted rows.
  ///
  /// The returned [RestaurantTable]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<RestaurantTable>> insert(
    _i1.DatabaseSession session,
    List<RestaurantTable> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<RestaurantTable>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [RestaurantTable] and returns the inserted row.
  ///
  /// The returned [RestaurantTable] will have its `id` field set.
  Future<RestaurantTable> insertRow(
    _i1.DatabaseSession session,
    RestaurantTable row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<RestaurantTable>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [RestaurantTable]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<RestaurantTable>> update(
    _i1.DatabaseSession session,
    List<RestaurantTable> rows, {
    _i1.ColumnSelections<RestaurantTableTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<RestaurantTable>(
      rows,
      columns: columns?.call(RestaurantTable.t),
      transaction: transaction,
    );
  }

  /// Updates a single [RestaurantTable]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<RestaurantTable> updateRow(
    _i1.DatabaseSession session,
    RestaurantTable row, {
    _i1.ColumnSelections<RestaurantTableTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<RestaurantTable>(
      row,
      columns: columns?.call(RestaurantTable.t),
      transaction: transaction,
    );
  }

  /// Updates a single [RestaurantTable] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<RestaurantTable?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<RestaurantTableUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<RestaurantTable>(
      id,
      columnValues: columnValues(RestaurantTable.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [RestaurantTable]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<RestaurantTable>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<RestaurantTableUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<RestaurantTableTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<RestaurantTableTable>? orderBy,
    _i1.OrderByListBuilder<RestaurantTableTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<RestaurantTable>(
      columnValues: columnValues(RestaurantTable.t.updateTable),
      where: where(RestaurantTable.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RestaurantTable.t),
      orderByList: orderByList?.call(RestaurantTable.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [RestaurantTable]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<RestaurantTable>> delete(
    _i1.DatabaseSession session,
    List<RestaurantTable> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<RestaurantTable>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [RestaurantTable].
  Future<RestaurantTable> deleteRow(
    _i1.DatabaseSession session,
    RestaurantTable row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<RestaurantTable>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<RestaurantTable>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<RestaurantTableTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<RestaurantTable>(
      where: where(RestaurantTable.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<RestaurantTableTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<RestaurantTable>(
      where: where?.call(RestaurantTable.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [RestaurantTable] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<RestaurantTableTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<RestaurantTable>(
      where: where(RestaurantTable.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
