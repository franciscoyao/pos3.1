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

abstract class Bill implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  Bill._({
    this.id,
    required this.billNumber,
    this.orderType,
    this.tableNo,
    this.waiterName,
    this.paymentMethod,
    this.taxNumber,
    double? subtotal,
    double? taxAmount,
    double? serviceAmount,
    double? tipAmount,
    required this.total,
    this.createdAt,
  }) : subtotal = subtotal ?? 0.0,
       taxAmount = taxAmount ?? 0.0,
       serviceAmount = serviceAmount ?? 0.0,
       tipAmount = tipAmount ?? 0.0;

  factory Bill({
    int? id,
    required String billNumber,
    String? orderType,
    String? tableNo,
    String? waiterName,
    String? paymentMethod,
    String? taxNumber,
    double? subtotal,
    double? taxAmount,
    double? serviceAmount,
    double? tipAmount,
    required double total,
    DateTime? createdAt,
  }) = _BillImpl;

  factory Bill.fromJson(Map<String, dynamic> jsonSerialization) {
    return Bill(
      id: jsonSerialization['id'] as int?,
      billNumber: jsonSerialization['billNumber'] as String,
      orderType: jsonSerialization['orderType'] as String?,
      tableNo: jsonSerialization['tableNo'] as String?,
      waiterName: jsonSerialization['waiterName'] as String?,
      paymentMethod: jsonSerialization['paymentMethod'] as String?,
      taxNumber: jsonSerialization['taxNumber'] as String?,
      subtotal: (jsonSerialization['subtotal'] as num?)?.toDouble(),
      taxAmount: (jsonSerialization['taxAmount'] as num?)?.toDouble(),
      serviceAmount: (jsonSerialization['serviceAmount'] as num?)?.toDouble(),
      tipAmount: (jsonSerialization['tipAmount'] as num?)?.toDouble(),
      total: (jsonSerialization['total'] as num).toDouble(),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = BillTable();

  static const db = BillRepository._();

  @override
  int? id;

  String billNumber;

  String? orderType;

  String? tableNo;

  String? waiterName;

  String? paymentMethod;

  String? taxNumber;

  double subtotal;

  double taxAmount;

  double serviceAmount;

  double tipAmount;

  double total;

  DateTime? createdAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [Bill]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Bill copyWith({
    int? id,
    String? billNumber,
    String? orderType,
    String? tableNo,
    String? waiterName,
    String? paymentMethod,
    String? taxNumber,
    double? subtotal,
    double? taxAmount,
    double? serviceAmount,
    double? tipAmount,
    double? total,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Bill',
      if (id != null) 'id': id,
      'billNumber': billNumber,
      if (orderType != null) 'orderType': orderType,
      if (tableNo != null) 'tableNo': tableNo,
      if (waiterName != null) 'waiterName': waiterName,
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
      if (taxNumber != null) 'taxNumber': taxNumber,
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'serviceAmount': serviceAmount,
      'tipAmount': tipAmount,
      'total': total,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Bill',
      if (id != null) 'id': id,
      'billNumber': billNumber,
      if (orderType != null) 'orderType': orderType,
      if (tableNo != null) 'tableNo': tableNo,
      if (waiterName != null) 'waiterName': waiterName,
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
      if (taxNumber != null) 'taxNumber': taxNumber,
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'serviceAmount': serviceAmount,
      'tipAmount': tipAmount,
      'total': total,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
    };
  }

  static BillInclude include() {
    return BillInclude._();
  }

  static BillIncludeList includeList({
    _i1.WhereExpressionBuilder<BillTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<BillTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<BillTable>? orderByList,
    BillInclude? include,
  }) {
    return BillIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Bill.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Bill.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _BillImpl extends Bill {
  _BillImpl({
    int? id,
    required String billNumber,
    String? orderType,
    String? tableNo,
    String? waiterName,
    String? paymentMethod,
    String? taxNumber,
    double? subtotal,
    double? taxAmount,
    double? serviceAmount,
    double? tipAmount,
    required double total,
    DateTime? createdAt,
  }) : super._(
         id: id,
         billNumber: billNumber,
         orderType: orderType,
         tableNo: tableNo,
         waiterName: waiterName,
         paymentMethod: paymentMethod,
         taxNumber: taxNumber,
         subtotal: subtotal,
         taxAmount: taxAmount,
         serviceAmount: serviceAmount,
         tipAmount: tipAmount,
         total: total,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Bill]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Bill copyWith({
    Object? id = _Undefined,
    String? billNumber,
    Object? orderType = _Undefined,
    Object? tableNo = _Undefined,
    Object? waiterName = _Undefined,
    Object? paymentMethod = _Undefined,
    Object? taxNumber = _Undefined,
    double? subtotal,
    double? taxAmount,
    double? serviceAmount,
    double? tipAmount,
    double? total,
    Object? createdAt = _Undefined,
  }) {
    return Bill(
      id: id is int? ? id : this.id,
      billNumber: billNumber ?? this.billNumber,
      orderType: orderType is String? ? orderType : this.orderType,
      tableNo: tableNo is String? ? tableNo : this.tableNo,
      waiterName: waiterName is String? ? waiterName : this.waiterName,
      paymentMethod: paymentMethod is String?
          ? paymentMethod
          : this.paymentMethod,
      taxNumber: taxNumber is String? ? taxNumber : this.taxNumber,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      serviceAmount: serviceAmount ?? this.serviceAmount,
      tipAmount: tipAmount ?? this.tipAmount,
      total: total ?? this.total,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
    );
  }
}

class BillUpdateTable extends _i1.UpdateTable<BillTable> {
  BillUpdateTable(super.table);

  _i1.ColumnValue<String, String> billNumber(String value) => _i1.ColumnValue(
    table.billNumber,
    value,
  );

  _i1.ColumnValue<String, String> orderType(String? value) => _i1.ColumnValue(
    table.orderType,
    value,
  );

  _i1.ColumnValue<String, String> tableNo(String? value) => _i1.ColumnValue(
    table.tableNo,
    value,
  );

  _i1.ColumnValue<String, String> waiterName(String? value) => _i1.ColumnValue(
    table.waiterName,
    value,
  );

  _i1.ColumnValue<String, String> paymentMethod(String? value) =>
      _i1.ColumnValue(
        table.paymentMethod,
        value,
      );

  _i1.ColumnValue<String, String> taxNumber(String? value) => _i1.ColumnValue(
    table.taxNumber,
    value,
  );

  _i1.ColumnValue<double, double> subtotal(double value) => _i1.ColumnValue(
    table.subtotal,
    value,
  );

  _i1.ColumnValue<double, double> taxAmount(double value) => _i1.ColumnValue(
    table.taxAmount,
    value,
  );

  _i1.ColumnValue<double, double> serviceAmount(double value) =>
      _i1.ColumnValue(
        table.serviceAmount,
        value,
      );

  _i1.ColumnValue<double, double> tipAmount(double value) => _i1.ColumnValue(
    table.tipAmount,
    value,
  );

  _i1.ColumnValue<double, double> total(double value) => _i1.ColumnValue(
    table.total,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime? value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class BillTable extends _i1.Table<int?> {
  BillTable({super.tableRelation}) : super(tableName: 'bills') {
    updateTable = BillUpdateTable(this);
    billNumber = _i1.ColumnString(
      'billNumber',
      this,
    );
    orderType = _i1.ColumnString(
      'orderType',
      this,
    );
    tableNo = _i1.ColumnString(
      'tableNo',
      this,
    );
    waiterName = _i1.ColumnString(
      'waiterName',
      this,
    );
    paymentMethod = _i1.ColumnString(
      'paymentMethod',
      this,
    );
    taxNumber = _i1.ColumnString(
      'taxNumber',
      this,
    );
    subtotal = _i1.ColumnDouble(
      'subtotal',
      this,
      hasDefault: true,
    );
    taxAmount = _i1.ColumnDouble(
      'taxAmount',
      this,
      hasDefault: true,
    );
    serviceAmount = _i1.ColumnDouble(
      'serviceAmount',
      this,
      hasDefault: true,
    );
    tipAmount = _i1.ColumnDouble(
      'tipAmount',
      this,
      hasDefault: true,
    );
    total = _i1.ColumnDouble(
      'total',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final BillUpdateTable updateTable;

  late final _i1.ColumnString billNumber;

  late final _i1.ColumnString orderType;

  late final _i1.ColumnString tableNo;

  late final _i1.ColumnString waiterName;

  late final _i1.ColumnString paymentMethod;

  late final _i1.ColumnString taxNumber;

  late final _i1.ColumnDouble subtotal;

  late final _i1.ColumnDouble taxAmount;

  late final _i1.ColumnDouble serviceAmount;

  late final _i1.ColumnDouble tipAmount;

  late final _i1.ColumnDouble total;

  late final _i1.ColumnDateTime createdAt;

  @override
  List<_i1.Column> get columns => [
    id,
    billNumber,
    orderType,
    tableNo,
    waiterName,
    paymentMethod,
    taxNumber,
    subtotal,
    taxAmount,
    serviceAmount,
    tipAmount,
    total,
    createdAt,
  ];
}

class BillInclude extends _i1.IncludeObject {
  BillInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => Bill.t;
}

class BillIncludeList extends _i1.IncludeList {
  BillIncludeList._({
    _i1.WhereExpressionBuilder<BillTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Bill.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => Bill.t;
}

class BillRepository {
  const BillRepository._();

  /// Returns a list of [Bill]s matching the given query parameters.
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
  Future<List<Bill>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<BillTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<BillTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<BillTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Bill>(
      where: where?.call(Bill.t),
      orderBy: orderBy?.call(Bill.t),
      orderByList: orderByList?.call(Bill.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Bill] matching the given query parameters.
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
  Future<Bill?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<BillTable>? where,
    int? offset,
    _i1.OrderByBuilder<BillTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<BillTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Bill>(
      where: where?.call(Bill.t),
      orderBy: orderBy?.call(Bill.t),
      orderByList: orderByList?.call(Bill.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Bill] by its [id] or null if no such row exists.
  Future<Bill?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Bill>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Bill]s in the list and returns the inserted rows.
  ///
  /// The returned [Bill]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<Bill>> insert(
    _i1.DatabaseSession session,
    List<Bill> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<Bill>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [Bill] and returns the inserted row.
  ///
  /// The returned [Bill] will have its `id` field set.
  Future<Bill> insertRow(
    _i1.DatabaseSession session,
    Bill row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Bill>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Bill]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Bill>> update(
    _i1.DatabaseSession session,
    List<Bill> rows, {
    _i1.ColumnSelections<BillTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Bill>(
      rows,
      columns: columns?.call(Bill.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Bill]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Bill> updateRow(
    _i1.DatabaseSession session,
    Bill row, {
    _i1.ColumnSelections<BillTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Bill>(
      row,
      columns: columns?.call(Bill.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Bill] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Bill?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<BillUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<Bill>(
      id,
      columnValues: columnValues(Bill.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Bill]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<Bill>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<BillUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<BillTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<BillTable>? orderBy,
    _i1.OrderByListBuilder<BillTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<Bill>(
      columnValues: columnValues(Bill.t.updateTable),
      where: where(Bill.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Bill.t),
      orderByList: orderByList?.call(Bill.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [Bill]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Bill>> delete(
    _i1.DatabaseSession session,
    List<Bill> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Bill>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Bill].
  Future<Bill> deleteRow(
    _i1.DatabaseSession session,
    Bill row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Bill>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Bill>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<BillTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Bill>(
      where: where(Bill.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<BillTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Bill>(
      where: where?.call(Bill.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Bill] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<BillTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Bill>(
      where: where(Bill.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
