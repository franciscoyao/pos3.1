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
import 'product_extra.dart' as _i2;
import 'package:pos_server_server/src/generated/protocol.dart' as _i3;

abstract class Product
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  Product._({
    this.id,
    this.categoryId,
    this.subcategoryId,
    this.itemCode,
    required this.name,
    required this.price,
    this.imageUrl,
    this.station,
    this.type,
    bool? isAvailable,
    bool? allowPriceEdit,
    bool? isDeleted,
    this.extras,
  }) : isAvailable = isAvailable ?? true,
       allowPriceEdit = allowPriceEdit ?? false,
       isDeleted = isDeleted ?? false;

  factory Product({
    int? id,
    int? categoryId,
    int? subcategoryId,
    String? itemCode,
    required String name,
    required double price,
    String? imageUrl,
    String? station,
    String? type,
    bool? isAvailable,
    bool? allowPriceEdit,
    bool? isDeleted,
    List<_i2.ProductExtra>? extras,
  }) = _ProductImpl;

  factory Product.fromJson(Map<String, dynamic> jsonSerialization) {
    return Product(
      id: jsonSerialization['id'] as int?,
      categoryId: jsonSerialization['categoryId'] as int?,
      subcategoryId: jsonSerialization['subcategoryId'] as int?,
      itemCode: jsonSerialization['itemCode'] as String?,
      name: jsonSerialization['name'] as String,
      price: (jsonSerialization['price'] as num).toDouble(),
      imageUrl: jsonSerialization['imageUrl'] as String?,
      station: jsonSerialization['station'] as String?,
      type: jsonSerialization['type'] as String?,
      isAvailable: jsonSerialization['isAvailable'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['isAvailable']),
      allowPriceEdit: jsonSerialization['allowPriceEdit'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['allowPriceEdit']),
      isDeleted: jsonSerialization['isDeleted'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['isDeleted']),
      extras: jsonSerialization['extras'] == null
          ? null
          : _i3.Protocol().deserialize<List<_i2.ProductExtra>>(
              jsonSerialization['extras'],
            ),
    );
  }

  static final t = ProductTable();

  static const db = ProductRepository._();

  @override
  int? id;

  int? categoryId;

  int? subcategoryId;

  String? itemCode;

  String name;

  double price;

  String? imageUrl;

  String? station;

  String? type;

  bool isAvailable;

  bool allowPriceEdit;

  bool isDeleted;

  List<_i2.ProductExtra>? extras;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [Product]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Product copyWith({
    int? id,
    int? categoryId,
    int? subcategoryId,
    String? itemCode,
    String? name,
    double? price,
    String? imageUrl,
    String? station,
    String? type,
    bool? isAvailable,
    bool? allowPriceEdit,
    bool? isDeleted,
    List<_i2.ProductExtra>? extras,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Product',
      if (id != null) 'id': id,
      if (categoryId != null) 'categoryId': categoryId,
      if (subcategoryId != null) 'subcategoryId': subcategoryId,
      if (itemCode != null) 'itemCode': itemCode,
      'name': name,
      'price': price,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (station != null) 'station': station,
      if (type != null) 'type': type,
      'isAvailable': isAvailable,
      'allowPriceEdit': allowPriceEdit,
      'isDeleted': isDeleted,
      if (extras != null)
        'extras': extras?.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Product',
      if (id != null) 'id': id,
      if (categoryId != null) 'categoryId': categoryId,
      if (subcategoryId != null) 'subcategoryId': subcategoryId,
      if (itemCode != null) 'itemCode': itemCode,
      'name': name,
      'price': price,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (station != null) 'station': station,
      if (type != null) 'type': type,
      'isAvailable': isAvailable,
      'allowPriceEdit': allowPriceEdit,
      'isDeleted': isDeleted,
      if (extras != null)
        'extras': extras?.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  static ProductInclude include() {
    return ProductInclude._();
  }

  static ProductIncludeList includeList({
    _i1.WhereExpressionBuilder<ProductTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ProductTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ProductTable>? orderByList,
    ProductInclude? include,
  }) {
    return ProductIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Product.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Product.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ProductImpl extends Product {
  _ProductImpl({
    int? id,
    int? categoryId,
    int? subcategoryId,
    String? itemCode,
    required String name,
    required double price,
    String? imageUrl,
    String? station,
    String? type,
    bool? isAvailable,
    bool? allowPriceEdit,
    bool? isDeleted,
    List<_i2.ProductExtra>? extras,
  }) : super._(
         id: id,
         categoryId: categoryId,
         subcategoryId: subcategoryId,
         itemCode: itemCode,
         name: name,
         price: price,
         imageUrl: imageUrl,
         station: station,
         type: type,
         isAvailable: isAvailable,
         allowPriceEdit: allowPriceEdit,
         isDeleted: isDeleted,
         extras: extras,
       );

  /// Returns a shallow copy of this [Product]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Product copyWith({
    Object? id = _Undefined,
    Object? categoryId = _Undefined,
    Object? subcategoryId = _Undefined,
    Object? itemCode = _Undefined,
    String? name,
    double? price,
    Object? imageUrl = _Undefined,
    Object? station = _Undefined,
    Object? type = _Undefined,
    bool? isAvailable,
    bool? allowPriceEdit,
    bool? isDeleted,
    Object? extras = _Undefined,
  }) {
    return Product(
      id: id is int? ? id : this.id,
      categoryId: categoryId is int? ? categoryId : this.categoryId,
      subcategoryId: subcategoryId is int? ? subcategoryId : this.subcategoryId,
      itemCode: itemCode is String? ? itemCode : this.itemCode,
      name: name ?? this.name,
      price: price ?? this.price,
      imageUrl: imageUrl is String? ? imageUrl : this.imageUrl,
      station: station is String? ? station : this.station,
      type: type is String? ? type : this.type,
      isAvailable: isAvailable ?? this.isAvailable,
      allowPriceEdit: allowPriceEdit ?? this.allowPriceEdit,
      isDeleted: isDeleted ?? this.isDeleted,
      extras: extras is List<_i2.ProductExtra>?
          ? extras
          : this.extras?.map((e0) => e0.copyWith()).toList(),
    );
  }
}

class ProductUpdateTable extends _i1.UpdateTable<ProductTable> {
  ProductUpdateTable(super.table);

  _i1.ColumnValue<int, int> categoryId(int? value) => _i1.ColumnValue(
    table.categoryId,
    value,
  );

  _i1.ColumnValue<int, int> subcategoryId(int? value) => _i1.ColumnValue(
    table.subcategoryId,
    value,
  );

  _i1.ColumnValue<String, String> itemCode(String? value) => _i1.ColumnValue(
    table.itemCode,
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

  _i1.ColumnValue<String, String> imageUrl(String? value) => _i1.ColumnValue(
    table.imageUrl,
    value,
  );

  _i1.ColumnValue<String, String> station(String? value) => _i1.ColumnValue(
    table.station,
    value,
  );

  _i1.ColumnValue<String, String> type(String? value) => _i1.ColumnValue(
    table.type,
    value,
  );

  _i1.ColumnValue<bool, bool> isAvailable(bool value) => _i1.ColumnValue(
    table.isAvailable,
    value,
  );

  _i1.ColumnValue<bool, bool> allowPriceEdit(bool value) => _i1.ColumnValue(
    table.allowPriceEdit,
    value,
  );

  _i1.ColumnValue<bool, bool> isDeleted(bool value) => _i1.ColumnValue(
    table.isDeleted,
    value,
  );

  _i1.ColumnValue<List<_i2.ProductExtra>, List<_i2.ProductExtra>> extras(
    List<_i2.ProductExtra>? value,
  ) => _i1.ColumnValue(
    table.extras,
    value,
  );
}

class ProductTable extends _i1.Table<int?> {
  ProductTable({super.tableRelation}) : super(tableName: 'products') {
    updateTable = ProductUpdateTable(this);
    categoryId = _i1.ColumnInt(
      'categoryId',
      this,
    );
    subcategoryId = _i1.ColumnInt(
      'subcategoryId',
      this,
    );
    itemCode = _i1.ColumnString(
      'itemCode',
      this,
    );
    name = _i1.ColumnString(
      'name',
      this,
    );
    price = _i1.ColumnDouble(
      'price',
      this,
    );
    imageUrl = _i1.ColumnString(
      'imageUrl',
      this,
    );
    station = _i1.ColumnString(
      'station',
      this,
    );
    type = _i1.ColumnString(
      'type',
      this,
    );
    isAvailable = _i1.ColumnBool(
      'isAvailable',
      this,
      hasDefault: true,
    );
    allowPriceEdit = _i1.ColumnBool(
      'allowPriceEdit',
      this,
      hasDefault: true,
    );
    isDeleted = _i1.ColumnBool(
      'isDeleted',
      this,
      hasDefault: true,
    );
    extras = _i1.ColumnSerializable<List<_i2.ProductExtra>>(
      'extras',
      this,
    );
  }

  late final ProductUpdateTable updateTable;

  late final _i1.ColumnInt categoryId;

  late final _i1.ColumnInt subcategoryId;

  late final _i1.ColumnString itemCode;

  late final _i1.ColumnString name;

  late final _i1.ColumnDouble price;

  late final _i1.ColumnString imageUrl;

  late final _i1.ColumnString station;

  late final _i1.ColumnString type;

  late final _i1.ColumnBool isAvailable;

  late final _i1.ColumnBool allowPriceEdit;

  late final _i1.ColumnBool isDeleted;

  late final _i1.ColumnSerializable<List<_i2.ProductExtra>> extras;

  @override
  List<_i1.Column> get columns => [
    id,
    categoryId,
    subcategoryId,
    itemCode,
    name,
    price,
    imageUrl,
    station,
    type,
    isAvailable,
    allowPriceEdit,
    isDeleted,
    extras,
  ];
}

class ProductInclude extends _i1.IncludeObject {
  ProductInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => Product.t;
}

class ProductIncludeList extends _i1.IncludeList {
  ProductIncludeList._({
    _i1.WhereExpressionBuilder<ProductTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Product.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => Product.t;
}

class ProductRepository {
  const ProductRepository._();

  /// Returns a list of [Product]s matching the given query parameters.
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
  Future<List<Product>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ProductTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ProductTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ProductTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Product>(
      where: where?.call(Product.t),
      orderBy: orderBy?.call(Product.t),
      orderByList: orderByList?.call(Product.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Product] matching the given query parameters.
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
  Future<Product?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ProductTable>? where,
    int? offset,
    _i1.OrderByBuilder<ProductTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ProductTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Product>(
      where: where?.call(Product.t),
      orderBy: orderBy?.call(Product.t),
      orderByList: orderByList?.call(Product.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Product] by its [id] or null if no such row exists.
  Future<Product?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Product>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Product]s in the list and returns the inserted rows.
  ///
  /// The returned [Product]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<Product>> insert(
    _i1.DatabaseSession session,
    List<Product> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<Product>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [Product] and returns the inserted row.
  ///
  /// The returned [Product] will have its `id` field set.
  Future<Product> insertRow(
    _i1.DatabaseSession session,
    Product row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Product>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Product]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Product>> update(
    _i1.DatabaseSession session,
    List<Product> rows, {
    _i1.ColumnSelections<ProductTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Product>(
      rows,
      columns: columns?.call(Product.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Product]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Product> updateRow(
    _i1.DatabaseSession session,
    Product row, {
    _i1.ColumnSelections<ProductTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Product>(
      row,
      columns: columns?.call(Product.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Product] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Product?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<ProductUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<Product>(
      id,
      columnValues: columnValues(Product.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Product]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<Product>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<ProductUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<ProductTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ProductTable>? orderBy,
    _i1.OrderByListBuilder<ProductTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<Product>(
      columnValues: columnValues(Product.t.updateTable),
      where: where(Product.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Product.t),
      orderByList: orderByList?.call(Product.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [Product]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Product>> delete(
    _i1.DatabaseSession session,
    List<Product> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Product>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Product].
  Future<Product> deleteRow(
    _i1.DatabaseSession session,
    Product row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Product>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Product>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<ProductTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Product>(
      where: where(Product.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ProductTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Product>(
      where: where?.call(Product.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Product] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<ProductTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Product>(
      where: where(Product.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
