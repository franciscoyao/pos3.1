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

abstract class ProductExtra
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  ProductExtra._({
    this.id,
    required this.productId,
    required this.name,
    double? price,
  }) : price = price ?? 0.0;

  factory ProductExtra({
    int? id,
    required int productId,
    required String name,
    double? price,
  }) = _ProductExtraImpl;

  factory ProductExtra.fromJson(Map<String, dynamic> jsonSerialization) {
    return ProductExtra(
      id: jsonSerialization['id'] as int?,
      productId: jsonSerialization['productId'] as int,
      name: jsonSerialization['name'] as String,
      price: (jsonSerialization['price'] as num?)?.toDouble(),
    );
  }

  static final t = ProductExtraTable();

  static const db = ProductExtraRepository._();

  @override
  int? id;

  int productId;

  String name;

  double price;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [ProductExtra]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ProductExtra copyWith({
    int? id,
    int? productId,
    String? name,
    double? price,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ProductExtra',
      if (id != null) 'id': id,
      'productId': productId,
      'name': name,
      'price': price,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ProductExtra',
      if (id != null) 'id': id,
      'productId': productId,
      'name': name,
      'price': price,
    };
  }

  static ProductExtraInclude include() {
    return ProductExtraInclude._();
  }

  static ProductExtraIncludeList includeList({
    _i1.WhereExpressionBuilder<ProductExtraTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ProductExtraTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ProductExtraTable>? orderByList,
    ProductExtraInclude? include,
  }) {
    return ProductExtraIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ProductExtra.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(ProductExtra.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ProductExtraImpl extends ProductExtra {
  _ProductExtraImpl({
    int? id,
    required int productId,
    required String name,
    double? price,
  }) : super._(
         id: id,
         productId: productId,
         name: name,
         price: price,
       );

  /// Returns a shallow copy of this [ProductExtra]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ProductExtra copyWith({
    Object? id = _Undefined,
    int? productId,
    String? name,
    double? price,
  }) {
    return ProductExtra(
      id: id is int? ? id : this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      price: price ?? this.price,
    );
  }
}

class ProductExtraUpdateTable extends _i1.UpdateTable<ProductExtraTable> {
  ProductExtraUpdateTable(super.table);

  _i1.ColumnValue<int, int> productId(int value) => _i1.ColumnValue(
    table.productId,
    value,
  );

  _i1.ColumnValue<String, String> name(String value) => _i1.ColumnValue(
    table.name,
    value,
  );

  _i1.ColumnValue<double, double> price(double value) => _i1.ColumnValue(
    table.price,
    value,
  );
}

class ProductExtraTable extends _i1.Table<int?> {
  ProductExtraTable({super.tableRelation})
    : super(tableName: 'product_extras') {
    updateTable = ProductExtraUpdateTable(this);
    productId = _i1.ColumnInt(
      'productId',
      this,
    );
    name = _i1.ColumnString(
      'name',
      this,
    );
    price = _i1.ColumnDouble(
      'price',
      this,
      hasDefault: true,
    );
  }

  late final ProductExtraUpdateTable updateTable;

  late final _i1.ColumnInt productId;

  late final _i1.ColumnString name;

  late final _i1.ColumnDouble price;

  @override
  List<_i1.Column> get columns => [
    id,
    productId,
    name,
    price,
  ];
}

class ProductExtraInclude extends _i1.IncludeObject {
  ProductExtraInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => ProductExtra.t;
}

class ProductExtraIncludeList extends _i1.IncludeList {
  ProductExtraIncludeList._({
    _i1.WhereExpressionBuilder<ProductExtraTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ProductExtra.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => ProductExtra.t;
}

class ProductExtraRepository {
  const ProductExtraRepository._();

  /// Returns a list of [ProductExtra]s matching the given query parameters.
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
  Future<List<ProductExtra>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ProductExtraTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ProductExtraTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ProductExtraTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ProductExtra>(
      where: where?.call(ProductExtra.t),
      orderBy: orderBy?.call(ProductExtra.t),
      orderByList: orderByList?.call(ProductExtra.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ProductExtra] matching the given query parameters.
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
  Future<ProductExtra?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ProductExtraTable>? where,
    int? offset,
    _i1.OrderByBuilder<ProductExtraTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ProductExtraTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ProductExtra>(
      where: where?.call(ProductExtra.t),
      orderBy: orderBy?.call(ProductExtra.t),
      orderByList: orderByList?.call(ProductExtra.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ProductExtra] by its [id] or null if no such row exists.
  Future<ProductExtra?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ProductExtra>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ProductExtra]s in the list and returns the inserted rows.
  ///
  /// The returned [ProductExtra]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<ProductExtra>> insert(
    _i1.DatabaseSession session,
    List<ProductExtra> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<ProductExtra>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [ProductExtra] and returns the inserted row.
  ///
  /// The returned [ProductExtra] will have its `id` field set.
  Future<ProductExtra> insertRow(
    _i1.DatabaseSession session,
    ProductExtra row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<ProductExtra>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [ProductExtra]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<ProductExtra>> update(
    _i1.DatabaseSession session,
    List<ProductExtra> rows, {
    _i1.ColumnSelections<ProductExtraTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<ProductExtra>(
      rows,
      columns: columns?.call(ProductExtra.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ProductExtra]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ProductExtra> updateRow(
    _i1.DatabaseSession session,
    ProductExtra row, {
    _i1.ColumnSelections<ProductExtraTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<ProductExtra>(
      row,
      columns: columns?.call(ProductExtra.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ProductExtra] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ProductExtra?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<ProductExtraUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<ProductExtra>(
      id,
      columnValues: columnValues(ProductExtra.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ProductExtra]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<ProductExtra>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<ProductExtraUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<ProductExtraTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ProductExtraTable>? orderBy,
    _i1.OrderByListBuilder<ProductExtraTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<ProductExtra>(
      columnValues: columnValues(ProductExtra.t.updateTable),
      where: where(ProductExtra.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ProductExtra.t),
      orderByList: orderByList?.call(ProductExtra.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [ProductExtra]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<ProductExtra>> delete(
    _i1.DatabaseSession session,
    List<ProductExtra> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<ProductExtra>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [ProductExtra].
  Future<ProductExtra> deleteRow(
    _i1.DatabaseSession session,
    ProductExtra row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ProductExtra>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<ProductExtra>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<ProductExtraTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<ProductExtra>(
      where: where(ProductExtra.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ProductExtraTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<ProductExtra>(
      where: where?.call(ProductExtra.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ProductExtra] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<ProductExtraTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ProductExtra>(
      where: where(ProductExtra.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
