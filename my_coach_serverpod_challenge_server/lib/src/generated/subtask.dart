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

/// Subtask for breaking down tasks into smaller steps
abstract class Subtask
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  Subtask._({
    this.id,
    required this.taskId,
    required this.name,
    required this.orderIndex,
    required this.isCompleted,
    this.completedAt,
  });

  factory Subtask({
    int? id,
    required int taskId,
    required String name,
    required int orderIndex,
    required bool isCompleted,
    DateTime? completedAt,
  }) = _SubtaskImpl;

  factory Subtask.fromJson(Map<String, dynamic> jsonSerialization) {
    return Subtask(
      id: jsonSerialization['id'] as int?,
      taskId: jsonSerialization['taskId'] as int,
      name: jsonSerialization['name'] as String,
      orderIndex: jsonSerialization['orderIndex'] as int,
      isCompleted: jsonSerialization['isCompleted'] as bool,
      completedAt: jsonSerialization['completedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['completedAt'],
            ),
    );
  }

  static final t = SubtaskTable();

  static const db = SubtaskRepository._();

  @override
  int? id;

  /// Reference to the parent task
  int taskId;

  /// The name/description of the subtask
  String name;

  /// Order index for sorting subtasks
  int orderIndex;

  /// Whether the subtask has been completed
  bool isCompleted;

  /// When the subtask was marked as completed
  DateTime? completedAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [Subtask]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Subtask copyWith({
    int? id,
    int? taskId,
    String? name,
    int? orderIndex,
    bool? isCompleted,
    DateTime? completedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Subtask',
      if (id != null) 'id': id,
      'taskId': taskId,
      'name': name,
      'orderIndex': orderIndex,
      'isCompleted': isCompleted,
      if (completedAt != null) 'completedAt': completedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Subtask',
      if (id != null) 'id': id,
      'taskId': taskId,
      'name': name,
      'orderIndex': orderIndex,
      'isCompleted': isCompleted,
      if (completedAt != null) 'completedAt': completedAt?.toJson(),
    };
  }

  static SubtaskInclude include() {
    return SubtaskInclude._();
  }

  static SubtaskIncludeList includeList({
    _i1.WhereExpressionBuilder<SubtaskTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SubtaskTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SubtaskTable>? orderByList,
    SubtaskInclude? include,
  }) {
    return SubtaskIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Subtask.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Subtask.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SubtaskImpl extends Subtask {
  _SubtaskImpl({
    int? id,
    required int taskId,
    required String name,
    required int orderIndex,
    required bool isCompleted,
    DateTime? completedAt,
  }) : super._(
         id: id,
         taskId: taskId,
         name: name,
         orderIndex: orderIndex,
         isCompleted: isCompleted,
         completedAt: completedAt,
       );

  /// Returns a shallow copy of this [Subtask]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Subtask copyWith({
    Object? id = _Undefined,
    int? taskId,
    String? name,
    int? orderIndex,
    bool? isCompleted,
    Object? completedAt = _Undefined,
  }) {
    return Subtask(
      id: id is int? ? id : this.id,
      taskId: taskId ?? this.taskId,
      name: name ?? this.name,
      orderIndex: orderIndex ?? this.orderIndex,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt is DateTime? ? completedAt : this.completedAt,
    );
  }
}

class SubtaskUpdateTable extends _i1.UpdateTable<SubtaskTable> {
  SubtaskUpdateTable(super.table);

  _i1.ColumnValue<int, int> taskId(int value) => _i1.ColumnValue(
    table.taskId,
    value,
  );

  _i1.ColumnValue<String, String> name(String value) => _i1.ColumnValue(
    table.name,
    value,
  );

  _i1.ColumnValue<int, int> orderIndex(int value) => _i1.ColumnValue(
    table.orderIndex,
    value,
  );

  _i1.ColumnValue<bool, bool> isCompleted(bool value) => _i1.ColumnValue(
    table.isCompleted,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> completedAt(DateTime? value) =>
      _i1.ColumnValue(
        table.completedAt,
        value,
      );
}

class SubtaskTable extends _i1.Table<int?> {
  SubtaskTable({super.tableRelation}) : super(tableName: 'subtask') {
    updateTable = SubtaskUpdateTable(this);
    taskId = _i1.ColumnInt(
      'taskId',
      this,
    );
    name = _i1.ColumnString(
      'name',
      this,
    );
    orderIndex = _i1.ColumnInt(
      'orderIndex',
      this,
    );
    isCompleted = _i1.ColumnBool(
      'isCompleted',
      this,
    );
    completedAt = _i1.ColumnDateTime(
      'completedAt',
      this,
    );
  }

  late final SubtaskUpdateTable updateTable;

  /// Reference to the parent task
  late final _i1.ColumnInt taskId;

  /// The name/description of the subtask
  late final _i1.ColumnString name;

  /// Order index for sorting subtasks
  late final _i1.ColumnInt orderIndex;

  /// Whether the subtask has been completed
  late final _i1.ColumnBool isCompleted;

  /// When the subtask was marked as completed
  late final _i1.ColumnDateTime completedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    taskId,
    name,
    orderIndex,
    isCompleted,
    completedAt,
  ];
}

class SubtaskInclude extends _i1.IncludeObject {
  SubtaskInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => Subtask.t;
}

class SubtaskIncludeList extends _i1.IncludeList {
  SubtaskIncludeList._({
    _i1.WhereExpressionBuilder<SubtaskTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Subtask.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => Subtask.t;
}

class SubtaskRepository {
  const SubtaskRepository._();

  /// Returns a list of [Subtask]s matching the given query parameters.
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
  Future<List<Subtask>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<SubtaskTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SubtaskTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SubtaskTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<Subtask>(
      where: where?.call(Subtask.t),
      orderBy: orderBy?.call(Subtask.t),
      orderByList: orderByList?.call(Subtask.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [Subtask] matching the given query parameters.
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
  Future<Subtask?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<SubtaskTable>? where,
    int? offset,
    _i1.OrderByBuilder<SubtaskTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SubtaskTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<Subtask>(
      where: where?.call(Subtask.t),
      orderBy: orderBy?.call(Subtask.t),
      orderByList: orderByList?.call(Subtask.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [Subtask] by its [id] or null if no such row exists.
  Future<Subtask?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<Subtask>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [Subtask]s in the list and returns the inserted rows.
  ///
  /// The returned [Subtask]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<Subtask>> insert(
    _i1.Session session,
    List<Subtask> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<Subtask>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [Subtask] and returns the inserted row.
  ///
  /// The returned [Subtask] will have its `id` field set.
  Future<Subtask> insertRow(
    _i1.Session session,
    Subtask row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Subtask>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Subtask]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Subtask>> update(
    _i1.Session session,
    List<Subtask> rows, {
    _i1.ColumnSelections<SubtaskTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Subtask>(
      rows,
      columns: columns?.call(Subtask.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Subtask]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Subtask> updateRow(
    _i1.Session session,
    Subtask row, {
    _i1.ColumnSelections<SubtaskTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Subtask>(
      row,
      columns: columns?.call(Subtask.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Subtask] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Subtask?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<SubtaskUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<Subtask>(
      id,
      columnValues: columnValues(Subtask.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Subtask]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<Subtask>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<SubtaskUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<SubtaskTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SubtaskTable>? orderBy,
    _i1.OrderByListBuilder<SubtaskTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<Subtask>(
      columnValues: columnValues(Subtask.t.updateTable),
      where: where(Subtask.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Subtask.t),
      orderByList: orderByList?.call(Subtask.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [Subtask]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Subtask>> delete(
    _i1.Session session,
    List<Subtask> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Subtask>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Subtask].
  Future<Subtask> deleteRow(
    _i1.Session session,
    Subtask row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Subtask>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Subtask>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<SubtaskTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Subtask>(
      where: where(Subtask.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<SubtaskTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Subtask>(
      where: where?.call(Subtask.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
