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

/// Individual reminder for a task (Google Calendar style - multiple reminders per task)
abstract class TaskReminder
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  TaskReminder._({
    this.id,
    required this.taskId,
    required this.minutesBefore,
    required this.isSent,
    this.sentAt,
  });

  factory TaskReminder({
    int? id,
    required int taskId,
    required int minutesBefore,
    required bool isSent,
    DateTime? sentAt,
  }) = _TaskReminderImpl;

  factory TaskReminder.fromJson(Map<String, dynamic> jsonSerialization) {
    return TaskReminder(
      id: jsonSerialization['id'] as int?,
      taskId: jsonSerialization['taskId'] as int,
      minutesBefore: jsonSerialization['minutesBefore'] as int,
      isSent: jsonSerialization['isSent'] as bool,
      sentAt: jsonSerialization['sentAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['sentAt']),
    );
  }

  static final t = TaskReminderTable();

  static const db = TaskReminderRepository._();

  @override
  int? id;

  /// Reference to the parent task
  int taskId;

  /// Minutes before due time to send reminder (0 = at due time, 30 = 30 min before, 1440 = 1 day before)
  int minutesBefore;

  /// Whether this reminder has been sent
  bool isSent;

  /// When the reminder was sent
  DateTime? sentAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [TaskReminder]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  TaskReminder copyWith({
    int? id,
    int? taskId,
    int? minutesBefore,
    bool? isSent,
    DateTime? sentAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TaskReminder',
      if (id != null) 'id': id,
      'taskId': taskId,
      'minutesBefore': minutesBefore,
      'isSent': isSent,
      if (sentAt != null) 'sentAt': sentAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TaskReminder',
      if (id != null) 'id': id,
      'taskId': taskId,
      'minutesBefore': minutesBefore,
      'isSent': isSent,
      if (sentAt != null) 'sentAt': sentAt?.toJson(),
    };
  }

  static TaskReminderInclude include() {
    return TaskReminderInclude._();
  }

  static TaskReminderIncludeList includeList({
    _i1.WhereExpressionBuilder<TaskReminderTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<TaskReminderTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<TaskReminderTable>? orderByList,
    TaskReminderInclude? include,
  }) {
    return TaskReminderIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(TaskReminder.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(TaskReminder.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TaskReminderImpl extends TaskReminder {
  _TaskReminderImpl({
    int? id,
    required int taskId,
    required int minutesBefore,
    required bool isSent,
    DateTime? sentAt,
  }) : super._(
         id: id,
         taskId: taskId,
         minutesBefore: minutesBefore,
         isSent: isSent,
         sentAt: sentAt,
       );

  /// Returns a shallow copy of this [TaskReminder]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  TaskReminder copyWith({
    Object? id = _Undefined,
    int? taskId,
    int? minutesBefore,
    bool? isSent,
    Object? sentAt = _Undefined,
  }) {
    return TaskReminder(
      id: id is int? ? id : this.id,
      taskId: taskId ?? this.taskId,
      minutesBefore: minutesBefore ?? this.minutesBefore,
      isSent: isSent ?? this.isSent,
      sentAt: sentAt is DateTime? ? sentAt : this.sentAt,
    );
  }
}

class TaskReminderUpdateTable extends _i1.UpdateTable<TaskReminderTable> {
  TaskReminderUpdateTable(super.table);

  _i1.ColumnValue<int, int> taskId(int value) => _i1.ColumnValue(
    table.taskId,
    value,
  );

  _i1.ColumnValue<int, int> minutesBefore(int value) => _i1.ColumnValue(
    table.minutesBefore,
    value,
  );

  _i1.ColumnValue<bool, bool> isSent(bool value) => _i1.ColumnValue(
    table.isSent,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> sentAt(DateTime? value) =>
      _i1.ColumnValue(
        table.sentAt,
        value,
      );
}

class TaskReminderTable extends _i1.Table<int?> {
  TaskReminderTable({super.tableRelation}) : super(tableName: 'task_reminder') {
    updateTable = TaskReminderUpdateTable(this);
    taskId = _i1.ColumnInt(
      'taskId',
      this,
    );
    minutesBefore = _i1.ColumnInt(
      'minutesBefore',
      this,
    );
    isSent = _i1.ColumnBool(
      'isSent',
      this,
    );
    sentAt = _i1.ColumnDateTime(
      'sentAt',
      this,
    );
  }

  late final TaskReminderUpdateTable updateTable;

  /// Reference to the parent task
  late final _i1.ColumnInt taskId;

  /// Minutes before due time to send reminder (0 = at due time, 30 = 30 min before, 1440 = 1 day before)
  late final _i1.ColumnInt minutesBefore;

  /// Whether this reminder has been sent
  late final _i1.ColumnBool isSent;

  /// When the reminder was sent
  late final _i1.ColumnDateTime sentAt;

  @override
  List<_i1.Column> get columns => [
    id,
    taskId,
    minutesBefore,
    isSent,
    sentAt,
  ];
}

class TaskReminderInclude extends _i1.IncludeObject {
  TaskReminderInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => TaskReminder.t;
}

class TaskReminderIncludeList extends _i1.IncludeList {
  TaskReminderIncludeList._({
    _i1.WhereExpressionBuilder<TaskReminderTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(TaskReminder.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => TaskReminder.t;
}

class TaskReminderRepository {
  const TaskReminderRepository._();

  /// Returns a list of [TaskReminder]s matching the given query parameters.
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
  Future<List<TaskReminder>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<TaskReminderTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<TaskReminderTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<TaskReminderTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<TaskReminder>(
      where: where?.call(TaskReminder.t),
      orderBy: orderBy?.call(TaskReminder.t),
      orderByList: orderByList?.call(TaskReminder.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [TaskReminder] matching the given query parameters.
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
  Future<TaskReminder?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<TaskReminderTable>? where,
    int? offset,
    _i1.OrderByBuilder<TaskReminderTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<TaskReminderTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<TaskReminder>(
      where: where?.call(TaskReminder.t),
      orderBy: orderBy?.call(TaskReminder.t),
      orderByList: orderByList?.call(TaskReminder.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [TaskReminder] by its [id] or null if no such row exists.
  Future<TaskReminder?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<TaskReminder>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [TaskReminder]s in the list and returns the inserted rows.
  ///
  /// The returned [TaskReminder]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<TaskReminder>> insert(
    _i1.Session session,
    List<TaskReminder> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<TaskReminder>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [TaskReminder] and returns the inserted row.
  ///
  /// The returned [TaskReminder] will have its `id` field set.
  Future<TaskReminder> insertRow(
    _i1.Session session,
    TaskReminder row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<TaskReminder>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [TaskReminder]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<TaskReminder>> update(
    _i1.Session session,
    List<TaskReminder> rows, {
    _i1.ColumnSelections<TaskReminderTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<TaskReminder>(
      rows,
      columns: columns?.call(TaskReminder.t),
      transaction: transaction,
    );
  }

  /// Updates a single [TaskReminder]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<TaskReminder> updateRow(
    _i1.Session session,
    TaskReminder row, {
    _i1.ColumnSelections<TaskReminderTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<TaskReminder>(
      row,
      columns: columns?.call(TaskReminder.t),
      transaction: transaction,
    );
  }

  /// Updates a single [TaskReminder] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<TaskReminder?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<TaskReminderUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<TaskReminder>(
      id,
      columnValues: columnValues(TaskReminder.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [TaskReminder]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<TaskReminder>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<TaskReminderUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<TaskReminderTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<TaskReminderTable>? orderBy,
    _i1.OrderByListBuilder<TaskReminderTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<TaskReminder>(
      columnValues: columnValues(TaskReminder.t.updateTable),
      where: where(TaskReminder.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(TaskReminder.t),
      orderByList: orderByList?.call(TaskReminder.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [TaskReminder]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<TaskReminder>> delete(
    _i1.Session session,
    List<TaskReminder> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<TaskReminder>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [TaskReminder].
  Future<TaskReminder> deleteRow(
    _i1.Session session,
    TaskReminder row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<TaskReminder>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<TaskReminder>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<TaskReminderTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<TaskReminder>(
      where: where(TaskReminder.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<TaskReminderTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<TaskReminder>(
      where: where?.call(TaskReminder.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
