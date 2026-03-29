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

abstract class Subcategory
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  Subcategory._({
    this.id,
    required this.categoryId,
    required this.name,
    int? sortOrder,
  }) : sortOrder = sortOrder ?? 0;

  factory Subcategory({
    int? id,
    required int categoryId,
    required String name,
    int? sortOrder,
  }) = _SubcategoryImpl;

  factory Subcategory.fromJson(Map<String, dynamic> jsonSerialization) {
    return Subcategory(
      id: jsonSerialization['id'] as int?,
      categoryId: jsonSerialization['categoryId'] as int,
      name: jsonSerialization['name'] as String,
      sortOrder: jsonSerialization['sortOrder'] as int?,
    );
  }

  static final t = SubcategoryTable();

  static const db = SubcategoryRepository._();

  @override
  int? id;

  int categoryId;

  String name;

  int sortOrder;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [Subcategory]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Subcategory copyWith({
    int? id,
    int? categoryId,
    String? name,
    int? sortOrder,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Subcategory',
      if (id != null) 'id': id,
      'categoryId': categoryId,
      'name': name,
      'sortOrder': sortOrder,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Subcategory',
      if (id != null) 'id': id,
      'categoryId': categoryId,
      'name': name,
      'sortOrder': sortOrder,
    };
  }

  static SubcategoryInclude include() {
    return SubcategoryInclude._();
  }

  static SubcategoryIncludeList includeList({
    _i1.WhereExpressionBuilder<SubcategoryTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SubcategoryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SubcategoryTable>? orderByList,
    SubcategoryInclude? include,
  }) {
    return SubcategoryIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Subcategory.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Subcategory.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SubcategoryImpl extends Subcategory {
  _SubcategoryImpl({
    int? id,
    required int categoryId,
    required String name,
    int? sortOrder,
  }) : super._(
         id: id,
         categoryId: categoryId,
         name: name,
         sortOrder: sortOrder,
       );

  /// Returns a shallow copy of this [Subcategory]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Subcategory copyWith({
    Object? id = _Undefined,
    int? categoryId,
    String? name,
    int? sortOrder,
  }) {
    return Subcategory(
      id: id is int? ? id : this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

class SubcategoryUpdateTable extends _i1.UpdateTable<SubcategoryTable> {
  SubcategoryUpdateTable(super.table);

  _i1.ColumnValue<int, int> categoryId(int value) => _i1.ColumnValue(
    table.categoryId,
    value,
  );

  _i1.ColumnValue<String, String> name(String value) => _i1.ColumnValue(
    table.name,
    value,
  );

  _i1.ColumnValue<int, int> sortOrder(int value) => _i1.ColumnValue(
    table.sortOrder,
    value,
  );
}

class SubcategoryTable extends _i1.Table<int?> {
  SubcategoryTable({super.tableRelation}) : super(tableName: 'subcategories') {
    updateTable = SubcategoryUpdateTable(this);
    categoryId = _i1.ColumnInt(
      'categoryId',
      this,
    );
    name = _i1.ColumnString(
      'name',
      this,
    );
    sortOrder = _i1.ColumnInt(
      'sortOrder',
      this,
      hasDefault: true,
    );
  }

  late final SubcategoryUpdateTable updateTable;

  late final _i1.ColumnInt categoryId;

  late final _i1.ColumnString name;

  late final _i1.ColumnInt sortOrder;

  @override
  List<_i1.Column> get columns => [
    id,
    categoryId,
    name,
    sortOrder,
  ];
}

class SubcategoryInclude extends _i1.IncludeObject {
  SubcategoryInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => Subcategory.t;
}

class SubcategoryIncludeList extends _i1.IncludeList {
  SubcategoryIncludeList._({
    _i1.WhereExpressionBuilder<SubcategoryTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Subcategory.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => Subcategory.t;
}

class SubcategoryRepository {
  const SubcategoryRepository._();

  /// Returns a list of [Subcategory]s matching the given query parameters.
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
  Future<List<Subcategory>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<SubcategoryTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SubcategoryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SubcategoryTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Subcategory>(
      where: where?.call(Subcategory.t),
      orderBy: orderBy?.call(Subcategory.t),
      orderByList: orderByList?.call(Subcategory.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Subcategory] matching the given query parameters.
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
  Future<Subcategory?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<SubcategoryTable>? where,
    int? offset,
    _i1.OrderByBuilder<SubcategoryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SubcategoryTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Subcategory>(
      where: where?.call(Subcategory.t),
      orderBy: orderBy?.call(Subcategory.t),
      orderByList: orderByList?.call(Subcategory.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Subcategory] by its [id] or null if no such row exists.
  Future<Subcategory?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Subcategory>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Subcategory]s in the list and returns the inserted rows.
  ///
  /// The returned [Subcategory]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<Subcategory>> insert(
    _i1.DatabaseSession session,
    List<Subcategory> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<Subcategory>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [Subcategory] and returns the inserted row.
  ///
  /// The returned [Subcategory] will have its `id` field set.
  Future<Subcategory> insertRow(
    _i1.DatabaseSession session,
    Subcategory row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Subcategory>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Subcategory]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Subcategory>> update(
    _i1.DatabaseSession session,
    List<Subcategory> rows, {
    _i1.ColumnSelections<SubcategoryTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Subcategory>(
      rows,
      columns: columns?.call(Subcategory.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Subcategory]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Subcategory> updateRow(
    _i1.DatabaseSession session,
    Subcategory row, {
    _i1.ColumnSelections<SubcategoryTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Subcategory>(
      row,
      columns: columns?.call(Subcategory.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Subcategory] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Subcategory?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<SubcategoryUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<Subcategory>(
      id,
      columnValues: columnValues(Subcategory.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Subcategory]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<Subcategory>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<SubcategoryUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<SubcategoryTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SubcategoryTable>? orderBy,
    _i1.OrderByListBuilder<SubcategoryTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<Subcategory>(
      columnValues: columnValues(Subcategory.t.updateTable),
      where: where(Subcategory.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Subcategory.t),
      orderByList: orderByList?.call(Subcategory.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [Subcategory]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Subcategory>> delete(
    _i1.DatabaseSession session,
    List<Subcategory> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Subcategory>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Subcategory].
  Future<Subcategory> deleteRow(
    _i1.DatabaseSession session,
    Subcategory row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Subcategory>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Subcategory>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<SubcategoryTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Subcategory>(
      where: where(Subcategory.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<SubcategoryTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Subcategory>(
      where: where?.call(Subcategory.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Subcategory] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<SubcategoryTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Subcategory>(
      where: where(Subcategory.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
