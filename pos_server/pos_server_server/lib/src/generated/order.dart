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
import 'order_item.dart' as _i2;
import 'package:pos_server_server/src/generated/protocol.dart' as _i3;

abstract class PosOrder
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  PosOrder._({
    this.id,
    this.billId,
    this.orderCode,
    this.orderType,
    this.tableNo,
    String? status,
    this.waiterName,
    this.taxNumber,
    double? subtotal,
    double? taxAmount,
    double? serviceAmount,
    double? tipAmount,
    required this.total,
    this.initialSplitCount,
    this.remainingSplitCount,
    this.scheduledTime,
    this.createdAt,
    this.updatedAt,
    this.items,
  }) : status = status ?? 'Pending',
       subtotal = subtotal ?? 0.0,
       taxAmount = taxAmount ?? 0.0,
       serviceAmount = serviceAmount ?? 0.0,
       tipAmount = tipAmount ?? 0.0;

  factory PosOrder({
    int? id,
    int? billId,
    String? orderCode,
    String? orderType,
    String? tableNo,
    String? status,
    String? waiterName,
    String? taxNumber,
    double? subtotal,
    double? taxAmount,
    double? serviceAmount,
    double? tipAmount,
    required double total,
    int? initialSplitCount,
    int? remainingSplitCount,
    DateTime? scheduledTime,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<_i2.OrderItem>? items,
  }) = _PosOrderImpl;

  factory PosOrder.fromJson(Map<String, dynamic> jsonSerialization) {
    return PosOrder(
      id: jsonSerialization['id'] as int?,
      billId: jsonSerialization['billId'] as int?,
      orderCode: jsonSerialization['orderCode'] as String?,
      orderType: jsonSerialization['orderType'] as String?,
      tableNo: jsonSerialization['tableNo'] as String?,
      status: jsonSerialization['status'] as String?,
      waiterName: jsonSerialization['waiterName'] as String?,
      taxNumber: jsonSerialization['taxNumber'] as String?,
      subtotal: (jsonSerialization['subtotal'] as num?)?.toDouble(),
      taxAmount: (jsonSerialization['taxAmount'] as num?)?.toDouble(),
      serviceAmount: (jsonSerialization['serviceAmount'] as num?)?.toDouble(),
      tipAmount: (jsonSerialization['tipAmount'] as num?)?.toDouble(),
      total: (jsonSerialization['total'] as num).toDouble(),
      initialSplitCount: jsonSerialization['initialSplitCount'] as int?,
      remainingSplitCount: jsonSerialization['remainingSplitCount'] as int?,
      scheduledTime: jsonSerialization['scheduledTime'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['scheduledTime'],
            ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      items: jsonSerialization['items'] == null
          ? null
          : _i3.Protocol().deserialize<List<_i2.OrderItem>>(
              jsonSerialization['items'],
            ),
    );
  }

  static final t = PosOrderTable();

  static const db = PosOrderRepository._();

  @override
  int? id;

  int? billId;

  String? orderCode;

  String? orderType;

  String? tableNo;

  String status;

  String? waiterName;

  String? taxNumber;

  double subtotal;

  double taxAmount;

  double serviceAmount;

  double tipAmount;

  double total;

  int? initialSplitCount;

  int? remainingSplitCount;

  DateTime? scheduledTime;

  DateTime? createdAt;

  DateTime? updatedAt;

  List<_i2.OrderItem>? items;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [PosOrder]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PosOrder copyWith({
    int? id,
    int? billId,
    String? orderCode,
    String? orderType,
    String? tableNo,
    String? status,
    String? waiterName,
    String? taxNumber,
    double? subtotal,
    double? taxAmount,
    double? serviceAmount,
    double? tipAmount,
    double? total,
    int? initialSplitCount,
    int? remainingSplitCount,
    DateTime? scheduledTime,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<_i2.OrderItem>? items,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PosOrder',
      if (id != null) 'id': id,
      if (billId != null) 'billId': billId,
      if (orderCode != null) 'orderCode': orderCode,
      if (orderType != null) 'orderType': orderType,
      if (tableNo != null) 'tableNo': tableNo,
      'status': status,
      if (waiterName != null) 'waiterName': waiterName,
      if (taxNumber != null) 'taxNumber': taxNumber,
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'serviceAmount': serviceAmount,
      'tipAmount': tipAmount,
      'total': total,
      if (initialSplitCount != null) 'initialSplitCount': initialSplitCount,
      if (remainingSplitCount != null)
        'remainingSplitCount': remainingSplitCount,
      if (scheduledTime != null) 'scheduledTime': scheduledTime?.toJson(),
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
      if (items != null) 'items': items?.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PosOrder',
      if (id != null) 'id': id,
      if (billId != null) 'billId': billId,
      if (orderCode != null) 'orderCode': orderCode,
      if (orderType != null) 'orderType': orderType,
      if (tableNo != null) 'tableNo': tableNo,
      'status': status,
      if (waiterName != null) 'waiterName': waiterName,
      if (taxNumber != null) 'taxNumber': taxNumber,
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'serviceAmount': serviceAmount,
      'tipAmount': tipAmount,
      'total': total,
      if (initialSplitCount != null) 'initialSplitCount': initialSplitCount,
      if (remainingSplitCount != null)
        'remainingSplitCount': remainingSplitCount,
      if (scheduledTime != null) 'scheduledTime': scheduledTime?.toJson(),
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
      if (items != null)
        'items': items?.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  static PosOrderInclude include() {
    return PosOrderInclude._();
  }

  static PosOrderIncludeList includeList({
    _i1.WhereExpressionBuilder<PosOrderTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PosOrderTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PosOrderTable>? orderByList,
    PosOrderInclude? include,
  }) {
    return PosOrderIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PosOrder.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(PosOrder.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PosOrderImpl extends PosOrder {
  _PosOrderImpl({
    int? id,
    int? billId,
    String? orderCode,
    String? orderType,
    String? tableNo,
    String? status,
    String? waiterName,
    String? taxNumber,
    double? subtotal,
    double? taxAmount,
    double? serviceAmount,
    double? tipAmount,
    required double total,
    int? initialSplitCount,
    int? remainingSplitCount,
    DateTime? scheduledTime,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<_i2.OrderItem>? items,
  }) : super._(
         id: id,
         billId: billId,
         orderCode: orderCode,
         orderType: orderType,
         tableNo: tableNo,
         status: status,
         waiterName: waiterName,
         taxNumber: taxNumber,
         subtotal: subtotal,
         taxAmount: taxAmount,
         serviceAmount: serviceAmount,
         tipAmount: tipAmount,
         total: total,
         initialSplitCount: initialSplitCount,
         remainingSplitCount: remainingSplitCount,
         scheduledTime: scheduledTime,
         createdAt: createdAt,
         updatedAt: updatedAt,
         items: items,
       );

  /// Returns a shallow copy of this [PosOrder]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PosOrder copyWith({
    Object? id = _Undefined,
    Object? billId = _Undefined,
    Object? orderCode = _Undefined,
    Object? orderType = _Undefined,
    Object? tableNo = _Undefined,
    String? status,
    Object? waiterName = _Undefined,
    Object? taxNumber = _Undefined,
    double? subtotal,
    double? taxAmount,
    double? serviceAmount,
    double? tipAmount,
    double? total,
    Object? initialSplitCount = _Undefined,
    Object? remainingSplitCount = _Undefined,
    Object? scheduledTime = _Undefined,
    Object? createdAt = _Undefined,
    Object? updatedAt = _Undefined,
    Object? items = _Undefined,
  }) {
    return PosOrder(
      id: id is int? ? id : this.id,
      billId: billId is int? ? billId : this.billId,
      orderCode: orderCode is String? ? orderCode : this.orderCode,
      orderType: orderType is String? ? orderType : this.orderType,
      tableNo: tableNo is String? ? tableNo : this.tableNo,
      status: status ?? this.status,
      waiterName: waiterName is String? ? waiterName : this.waiterName,
      taxNumber: taxNumber is String? ? taxNumber : this.taxNumber,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      serviceAmount: serviceAmount ?? this.serviceAmount,
      tipAmount: tipAmount ?? this.tipAmount,
      total: total ?? this.total,
      initialSplitCount: initialSplitCount is int?
          ? initialSplitCount
          : this.initialSplitCount,
      remainingSplitCount: remainingSplitCount is int?
          ? remainingSplitCount
          : this.remainingSplitCount,
      scheduledTime: scheduledTime is DateTime?
          ? scheduledTime
          : this.scheduledTime,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
      items: items is List<_i2.OrderItem>?
          ? items
          : this.items?.map((e0) => e0.copyWith()).toList(),
    );
  }
}

class PosOrderUpdateTable extends _i1.UpdateTable<PosOrderTable> {
  PosOrderUpdateTable(super.table);

  _i1.ColumnValue<int, int> billId(int? value) => _i1.ColumnValue(
    table.billId,
    value,
  );

  _i1.ColumnValue<String, String> orderCode(String? value) => _i1.ColumnValue(
    table.orderCode,
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

  _i1.ColumnValue<String, String> status(String value) => _i1.ColumnValue(
    table.status,
    value,
  );

  _i1.ColumnValue<String, String> waiterName(String? value) => _i1.ColumnValue(
    table.waiterName,
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

  _i1.ColumnValue<int, int> initialSplitCount(int? value) => _i1.ColumnValue(
    table.initialSplitCount,
    value,
  );

  _i1.ColumnValue<int, int> remainingSplitCount(int? value) => _i1.ColumnValue(
    table.remainingSplitCount,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> scheduledTime(DateTime? value) =>
      _i1.ColumnValue(
        table.scheduledTime,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime? value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> updatedAt(DateTime? value) =>
      _i1.ColumnValue(
        table.updatedAt,
        value,
      );

  _i1.ColumnValue<List<_i2.OrderItem>, List<_i2.OrderItem>> items(
    List<_i2.OrderItem>? value,
  ) => _i1.ColumnValue(
    table.items,
    value,
  );
}

class PosOrderTable extends _i1.Table<int?> {
  PosOrderTable({super.tableRelation}) : super(tableName: 'pos_orders') {
    updateTable = PosOrderUpdateTable(this);
    billId = _i1.ColumnInt(
      'billId',
      this,
    );
    orderCode = _i1.ColumnString(
      'orderCode',
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
    status = _i1.ColumnString(
      'status',
      this,
      hasDefault: true,
    );
    waiterName = _i1.ColumnString(
      'waiterName',
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
    initialSplitCount = _i1.ColumnInt(
      'initialSplitCount',
      this,
    );
    remainingSplitCount = _i1.ColumnInt(
      'remainingSplitCount',
      this,
    );
    scheduledTime = _i1.ColumnDateTime(
      'scheduledTime',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
    updatedAt = _i1.ColumnDateTime(
      'updatedAt',
      this,
    );
    items = _i1.ColumnSerializable<List<_i2.OrderItem>>(
      'items',
      this,
    );
  }

  late final PosOrderUpdateTable updateTable;

  late final _i1.ColumnInt billId;

  late final _i1.ColumnString orderCode;

  late final _i1.ColumnString orderType;

  late final _i1.ColumnString tableNo;

  late final _i1.ColumnString status;

  late final _i1.ColumnString waiterName;

  late final _i1.ColumnString taxNumber;

  late final _i1.ColumnDouble subtotal;

  late final _i1.ColumnDouble taxAmount;

  late final _i1.ColumnDouble serviceAmount;

  late final _i1.ColumnDouble tipAmount;

  late final _i1.ColumnDouble total;

  late final _i1.ColumnInt initialSplitCount;

  late final _i1.ColumnInt remainingSplitCount;

  late final _i1.ColumnDateTime scheduledTime;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  late final _i1.ColumnSerializable<List<_i2.OrderItem>> items;

  @override
  List<_i1.Column> get columns => [
    id,
    billId,
    orderCode,
    orderType,
    tableNo,
    status,
    waiterName,
    taxNumber,
    subtotal,
    taxAmount,
    serviceAmount,
    tipAmount,
    total,
    initialSplitCount,
    remainingSplitCount,
    scheduledTime,
    createdAt,
    updatedAt,
    items,
  ];
}

class PosOrderInclude extends _i1.IncludeObject {
  PosOrderInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => PosOrder.t;
}

class PosOrderIncludeList extends _i1.IncludeList {
  PosOrderIncludeList._({
    _i1.WhereExpressionBuilder<PosOrderTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PosOrder.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => PosOrder.t;
}

class PosOrderRepository {
  const PosOrderRepository._();

  /// Returns a list of [PosOrder]s matching the given query parameters.
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
  Future<List<PosOrder>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PosOrderTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PosOrderTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PosOrderTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<PosOrder>(
      where: where?.call(PosOrder.t),
      orderBy: orderBy?.call(PosOrder.t),
      orderByList: orderByList?.call(PosOrder.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [PosOrder] matching the given query parameters.
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
  Future<PosOrder?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PosOrderTable>? where,
    int? offset,
    _i1.OrderByBuilder<PosOrderTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PosOrderTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<PosOrder>(
      where: where?.call(PosOrder.t),
      orderBy: orderBy?.call(PosOrder.t),
      orderByList: orderByList?.call(PosOrder.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [PosOrder] by its [id] or null if no such row exists.
  Future<PosOrder?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<PosOrder>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [PosOrder]s in the list and returns the inserted rows.
  ///
  /// The returned [PosOrder]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<PosOrder>> insert(
    _i1.DatabaseSession session,
    List<PosOrder> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<PosOrder>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [PosOrder] and returns the inserted row.
  ///
  /// The returned [PosOrder] will have its `id` field set.
  Future<PosOrder> insertRow(
    _i1.DatabaseSession session,
    PosOrder row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<PosOrder>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [PosOrder]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<PosOrder>> update(
    _i1.DatabaseSession session,
    List<PosOrder> rows, {
    _i1.ColumnSelections<PosOrderTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<PosOrder>(
      rows,
      columns: columns?.call(PosOrder.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PosOrder]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PosOrder> updateRow(
    _i1.DatabaseSession session,
    PosOrder row, {
    _i1.ColumnSelections<PosOrderTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<PosOrder>(
      row,
      columns: columns?.call(PosOrder.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PosOrder] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PosOrder?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<PosOrderUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<PosOrder>(
      id,
      columnValues: columnValues(PosOrder.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PosOrder]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<PosOrder>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<PosOrderUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<PosOrderTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PosOrderTable>? orderBy,
    _i1.OrderByListBuilder<PosOrderTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<PosOrder>(
      columnValues: columnValues(PosOrder.t.updateTable),
      where: where(PosOrder.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PosOrder.t),
      orderByList: orderByList?.call(PosOrder.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [PosOrder]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<PosOrder>> delete(
    _i1.DatabaseSession session,
    List<PosOrder> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<PosOrder>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [PosOrder].
  Future<PosOrder> deleteRow(
    _i1.DatabaseSession session,
    PosOrder row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PosOrder>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<PosOrder>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<PosOrderTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<PosOrder>(
      where: where(PosOrder.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PosOrderTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<PosOrder>(
      where: where?.call(PosOrder.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PosOrder] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<PosOrderTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PosOrder>(
      where: where(PosOrder.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
