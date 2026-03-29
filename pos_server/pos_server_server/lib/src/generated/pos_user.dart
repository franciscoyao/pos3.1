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

abstract class PosUser
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  PosUser._({
    this.id,
    this.fullName,
    required this.username,
    this.pin,
    required this.role,
    String? status,
    bool? isDefault,
    this.createdAt,
  }) : status = status ?? 'Active',
       isDefault = isDefault ?? false;

  factory PosUser({
    int? id,
    String? fullName,
    required String username,
    String? pin,
    required String role,
    String? status,
    bool? isDefault,
    DateTime? createdAt,
  }) = _PosUserImpl;

  factory PosUser.fromJson(Map<String, dynamic> jsonSerialization) {
    return PosUser(
      id: jsonSerialization['id'] as int?,
      fullName: jsonSerialization['fullName'] as String?,
      username: jsonSerialization['username'] as String,
      pin: jsonSerialization['pin'] as String?,
      role: jsonSerialization['role'] as String,
      status: jsonSerialization['status'] as String?,
      isDefault: jsonSerialization['isDefault'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['isDefault']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = PosUserTable();

  static const db = PosUserRepository._();

  @override
  int? id;

  String? fullName;

  String username;

  String? pin;

  String role;

  String status;

  bool isDefault;

  DateTime? createdAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [PosUser]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PosUser copyWith({
    int? id,
    String? fullName,
    String? username,
    String? pin,
    String? role,
    String? status,
    bool? isDefault,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PosUser',
      if (id != null) 'id': id,
      if (fullName != null) 'fullName': fullName,
      'username': username,
      if (pin != null) 'pin': pin,
      'role': role,
      'status': status,
      'isDefault': isDefault,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PosUser',
      if (id != null) 'id': id,
      if (fullName != null) 'fullName': fullName,
      'username': username,
      if (pin != null) 'pin': pin,
      'role': role,
      'status': status,
      'isDefault': isDefault,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
    };
  }

  static PosUserInclude include() {
    return PosUserInclude._();
  }

  static PosUserIncludeList includeList({
    _i1.WhereExpressionBuilder<PosUserTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PosUserTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PosUserTable>? orderByList,
    PosUserInclude? include,
  }) {
    return PosUserIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PosUser.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(PosUser.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PosUserImpl extends PosUser {
  _PosUserImpl({
    int? id,
    String? fullName,
    required String username,
    String? pin,
    required String role,
    String? status,
    bool? isDefault,
    DateTime? createdAt,
  }) : super._(
         id: id,
         fullName: fullName,
         username: username,
         pin: pin,
         role: role,
         status: status,
         isDefault: isDefault,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [PosUser]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PosUser copyWith({
    Object? id = _Undefined,
    Object? fullName = _Undefined,
    String? username,
    Object? pin = _Undefined,
    String? role,
    String? status,
    bool? isDefault,
    Object? createdAt = _Undefined,
  }) {
    return PosUser(
      id: id is int? ? id : this.id,
      fullName: fullName is String? ? fullName : this.fullName,
      username: username ?? this.username,
      pin: pin is String? ? pin : this.pin,
      role: role ?? this.role,
      status: status ?? this.status,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
    );
  }
}

class PosUserUpdateTable extends _i1.UpdateTable<PosUserTable> {
  PosUserUpdateTable(super.table);

  _i1.ColumnValue<String, String> fullName(String? value) => _i1.ColumnValue(
    table.fullName,
    value,
  );

  _i1.ColumnValue<String, String> username(String value) => _i1.ColumnValue(
    table.username,
    value,
  );

  _i1.ColumnValue<String, String> pin(String? value) => _i1.ColumnValue(
    table.pin,
    value,
  );

  _i1.ColumnValue<String, String> role(String value) => _i1.ColumnValue(
    table.role,
    value,
  );

  _i1.ColumnValue<String, String> status(String value) => _i1.ColumnValue(
    table.status,
    value,
  );

  _i1.ColumnValue<bool, bool> isDefault(bool value) => _i1.ColumnValue(
    table.isDefault,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime? value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class PosUserTable extends _i1.Table<int?> {
  PosUserTable({super.tableRelation}) : super(tableName: 'pos_users') {
    updateTable = PosUserUpdateTable(this);
    fullName = _i1.ColumnString(
      'fullName',
      this,
    );
    username = _i1.ColumnString(
      'username',
      this,
    );
    pin = _i1.ColumnString(
      'pin',
      this,
    );
    role = _i1.ColumnString(
      'role',
      this,
    );
    status = _i1.ColumnString(
      'status',
      this,
      hasDefault: true,
    );
    isDefault = _i1.ColumnBool(
      'isDefault',
      this,
      hasDefault: true,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final PosUserUpdateTable updateTable;

  late final _i1.ColumnString fullName;

  late final _i1.ColumnString username;

  late final _i1.ColumnString pin;

  late final _i1.ColumnString role;

  late final _i1.ColumnString status;

  late final _i1.ColumnBool isDefault;

  late final _i1.ColumnDateTime createdAt;

  @override
  List<_i1.Column> get columns => [
    id,
    fullName,
    username,
    pin,
    role,
    status,
    isDefault,
    createdAt,
  ];
}

class PosUserInclude extends _i1.IncludeObject {
  PosUserInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => PosUser.t;
}

class PosUserIncludeList extends _i1.IncludeList {
  PosUserIncludeList._({
    _i1.WhereExpressionBuilder<PosUserTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PosUser.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => PosUser.t;
}

class PosUserRepository {
  const PosUserRepository._();

  /// Returns a list of [PosUser]s matching the given query parameters.
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
  Future<List<PosUser>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PosUserTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PosUserTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PosUserTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<PosUser>(
      where: where?.call(PosUser.t),
      orderBy: orderBy?.call(PosUser.t),
      orderByList: orderByList?.call(PosUser.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [PosUser] matching the given query parameters.
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
  Future<PosUser?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PosUserTable>? where,
    int? offset,
    _i1.OrderByBuilder<PosUserTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PosUserTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<PosUser>(
      where: where?.call(PosUser.t),
      orderBy: orderBy?.call(PosUser.t),
      orderByList: orderByList?.call(PosUser.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [PosUser] by its [id] or null if no such row exists.
  Future<PosUser?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<PosUser>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [PosUser]s in the list and returns the inserted rows.
  ///
  /// The returned [PosUser]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<PosUser>> insert(
    _i1.DatabaseSession session,
    List<PosUser> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<PosUser>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [PosUser] and returns the inserted row.
  ///
  /// The returned [PosUser] will have its `id` field set.
  Future<PosUser> insertRow(
    _i1.DatabaseSession session,
    PosUser row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<PosUser>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [PosUser]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<PosUser>> update(
    _i1.DatabaseSession session,
    List<PosUser> rows, {
    _i1.ColumnSelections<PosUserTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<PosUser>(
      rows,
      columns: columns?.call(PosUser.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PosUser]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PosUser> updateRow(
    _i1.DatabaseSession session,
    PosUser row, {
    _i1.ColumnSelections<PosUserTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<PosUser>(
      row,
      columns: columns?.call(PosUser.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PosUser] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PosUser?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<PosUserUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<PosUser>(
      id,
      columnValues: columnValues(PosUser.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PosUser]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<PosUser>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<PosUserUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<PosUserTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PosUserTable>? orderBy,
    _i1.OrderByListBuilder<PosUserTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<PosUser>(
      columnValues: columnValues(PosUser.t.updateTable),
      where: where(PosUser.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PosUser.t),
      orderByList: orderByList?.call(PosUser.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [PosUser]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<PosUser>> delete(
    _i1.DatabaseSession session,
    List<PosUser> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<PosUser>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [PosUser].
  Future<PosUser> deleteRow(
    _i1.DatabaseSession session,
    PosUser row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PosUser>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<PosUser>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<PosUserTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<PosUser>(
      where: where(PosUser.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PosUserTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<PosUser>(
      where: where?.call(PosUser.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PosUser] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<PosUserTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PosUser>(
      where: where(PosUser.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
