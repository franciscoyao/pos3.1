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

abstract class Settings
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  Settings._({
    this.id,
    required this.taxRate,
    required this.serviceCharge,
    required this.currencySymbol,
    required this.orderDelayThreshold,
    this.updatedAt,
  });

  factory Settings({
    int? id,
    required double taxRate,
    required double serviceCharge,
    required String currencySymbol,
    required int orderDelayThreshold,
    DateTime? updatedAt,
  }) = _SettingsImpl;

  factory Settings.fromJson(Map<String, dynamic> jsonSerialization) {
    return Settings(
      id: jsonSerialization['id'] as int?,
      taxRate: (jsonSerialization['taxRate'] as num).toDouble(),
      serviceCharge: (jsonSerialization['serviceCharge'] as num).toDouble(),
      currencySymbol: jsonSerialization['currencySymbol'] as String,
      orderDelayThreshold: jsonSerialization['orderDelayThreshold'] as int,
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = SettingsTable();

  static const db = SettingsRepository._();

  @override
  int? id;

  double taxRate;

  double serviceCharge;

  String currencySymbol;

  int orderDelayThreshold;

  DateTime? updatedAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [Settings]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Settings copyWith({
    int? id,
    double? taxRate,
    double? serviceCharge,
    String? currencySymbol,
    int? orderDelayThreshold,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Settings',
      if (id != null) 'id': id,
      'taxRate': taxRate,
      'serviceCharge': serviceCharge,
      'currencySymbol': currencySymbol,
      'orderDelayThreshold': orderDelayThreshold,
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Settings',
      if (id != null) 'id': id,
      'taxRate': taxRate,
      'serviceCharge': serviceCharge,
      'currencySymbol': currencySymbol,
      'orderDelayThreshold': orderDelayThreshold,
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  static SettingsInclude include() {
    return SettingsInclude._();
  }

  static SettingsIncludeList includeList({
    _i1.WhereExpressionBuilder<SettingsTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SettingsTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SettingsTable>? orderByList,
    SettingsInclude? include,
  }) {
    return SettingsIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Settings.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Settings.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SettingsImpl extends Settings {
  _SettingsImpl({
    int? id,
    required double taxRate,
    required double serviceCharge,
    required String currencySymbol,
    required int orderDelayThreshold,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         taxRate: taxRate,
         serviceCharge: serviceCharge,
         currencySymbol: currencySymbol,
         orderDelayThreshold: orderDelayThreshold,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [Settings]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Settings copyWith({
    Object? id = _Undefined,
    double? taxRate,
    double? serviceCharge,
    String? currencySymbol,
    int? orderDelayThreshold,
    Object? updatedAt = _Undefined,
  }) {
    return Settings(
      id: id is int? ? id : this.id,
      taxRate: taxRate ?? this.taxRate,
      serviceCharge: serviceCharge ?? this.serviceCharge,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      orderDelayThreshold: orderDelayThreshold ?? this.orderDelayThreshold,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
    );
  }
}

class SettingsUpdateTable extends _i1.UpdateTable<SettingsTable> {
  SettingsUpdateTable(super.table);

  _i1.ColumnValue<double, double> taxRate(double value) => _i1.ColumnValue(
    table.taxRate,
    value,
  );

  _i1.ColumnValue<double, double> serviceCharge(double value) =>
      _i1.ColumnValue(
        table.serviceCharge,
        value,
      );

  _i1.ColumnValue<String, String> currencySymbol(String value) =>
      _i1.ColumnValue(
        table.currencySymbol,
        value,
      );

  _i1.ColumnValue<int, int> orderDelayThreshold(int value) => _i1.ColumnValue(
    table.orderDelayThreshold,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> updatedAt(DateTime? value) =>
      _i1.ColumnValue(
        table.updatedAt,
        value,
      );
}

class SettingsTable extends _i1.Table<int?> {
  SettingsTable({super.tableRelation}) : super(tableName: 'settings') {
    updateTable = SettingsUpdateTable(this);
    taxRate = _i1.ColumnDouble(
      'taxRate',
      this,
    );
    serviceCharge = _i1.ColumnDouble(
      'serviceCharge',
      this,
    );
    currencySymbol = _i1.ColumnString(
      'currencySymbol',
      this,
    );
    orderDelayThreshold = _i1.ColumnInt(
      'orderDelayThreshold',
      this,
    );
    updatedAt = _i1.ColumnDateTime(
      'updatedAt',
      this,
    );
  }

  late final SettingsUpdateTable updateTable;

  late final _i1.ColumnDouble taxRate;

  late final _i1.ColumnDouble serviceCharge;

  late final _i1.ColumnString currencySymbol;

  late final _i1.ColumnInt orderDelayThreshold;

  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    taxRate,
    serviceCharge,
    currencySymbol,
    orderDelayThreshold,
    updatedAt,
  ];
}

class SettingsInclude extends _i1.IncludeObject {
  SettingsInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => Settings.t;
}

class SettingsIncludeList extends _i1.IncludeList {
  SettingsIncludeList._({
    _i1.WhereExpressionBuilder<SettingsTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Settings.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => Settings.t;
}

class SettingsRepository {
  const SettingsRepository._();

  /// Returns a list of [Settings]s matching the given query parameters.
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
  Future<List<Settings>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<SettingsTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SettingsTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SettingsTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Settings>(
      where: where?.call(Settings.t),
      orderBy: orderBy?.call(Settings.t),
      orderByList: orderByList?.call(Settings.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Settings] matching the given query parameters.
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
  Future<Settings?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<SettingsTable>? where,
    int? offset,
    _i1.OrderByBuilder<SettingsTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SettingsTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Settings>(
      where: where?.call(Settings.t),
      orderBy: orderBy?.call(Settings.t),
      orderByList: orderByList?.call(Settings.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Settings] by its [id] or null if no such row exists.
  Future<Settings?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Settings>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Settings]s in the list and returns the inserted rows.
  ///
  /// The returned [Settings]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<Settings>> insert(
    _i1.DatabaseSession session,
    List<Settings> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<Settings>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [Settings] and returns the inserted row.
  ///
  /// The returned [Settings] will have its `id` field set.
  Future<Settings> insertRow(
    _i1.DatabaseSession session,
    Settings row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Settings>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Settings]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Settings>> update(
    _i1.DatabaseSession session,
    List<Settings> rows, {
    _i1.ColumnSelections<SettingsTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Settings>(
      rows,
      columns: columns?.call(Settings.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Settings]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Settings> updateRow(
    _i1.DatabaseSession session,
    Settings row, {
    _i1.ColumnSelections<SettingsTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Settings>(
      row,
      columns: columns?.call(Settings.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Settings] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Settings?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<SettingsUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<Settings>(
      id,
      columnValues: columnValues(Settings.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Settings]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<Settings>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<SettingsUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<SettingsTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SettingsTable>? orderBy,
    _i1.OrderByListBuilder<SettingsTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<Settings>(
      columnValues: columnValues(Settings.t.updateTable),
      where: where(Settings.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Settings.t),
      orderByList: orderByList?.call(Settings.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [Settings]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Settings>> delete(
    _i1.DatabaseSession session,
    List<Settings> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Settings>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Settings].
  Future<Settings> deleteRow(
    _i1.DatabaseSession session,
    Settings row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Settings>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Settings>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<SettingsTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Settings>(
      where: where(Settings.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<SettingsTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Settings>(
      where: where?.call(Settings.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Settings] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<SettingsTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Settings>(
      where: where(Settings.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
