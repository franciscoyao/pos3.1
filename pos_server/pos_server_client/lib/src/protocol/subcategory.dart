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
import 'package:serverpod_client/serverpod_client.dart' as _i1;

abstract class Subcategory implements _i1.SerializableModel {
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

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int categoryId;

  String name;

  int sortOrder;

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
