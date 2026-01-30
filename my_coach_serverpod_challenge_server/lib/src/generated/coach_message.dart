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

/// AI-generated coach message with audio
abstract class CoachMessage
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  CoachMessage._({
    this.id,
    required this.taskId,
    required this.coachId,
    required this.textContent,
    this.audioStoragePath,
    required this.generatedAt,
  });

  factory CoachMessage({
    int? id,
    required int taskId,
    required int coachId,
    required String textContent,
    String? audioStoragePath,
    required DateTime generatedAt,
  }) = _CoachMessageImpl;

  factory CoachMessage.fromJson(Map<String, dynamic> jsonSerialization) {
    return CoachMessage(
      id: jsonSerialization['id'] as int?,
      taskId: jsonSerialization['taskId'] as int,
      coachId: jsonSerialization['coachId'] as int,
      textContent: jsonSerialization['textContent'] as String,
      audioStoragePath: jsonSerialization['audioStoragePath'] as String?,
      generatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['generatedAt'],
      ),
    );
  }

  static final t = CoachMessageTable();

  static const db = CoachMessageRepository._();

  @override
  int? id;

  /// Reference to the task this message is about
  int taskId;

  /// Reference to the coach who generated this message
  int coachId;

  /// The generated text content of the message
  String textContent;

  /// Path to the stored audio file (MP3)
  String? audioStoragePath;

  /// When this message was generated
  DateTime generatedAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [CoachMessage]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CoachMessage copyWith({
    int? id,
    int? taskId,
    int? coachId,
    String? textContent,
    String? audioStoragePath,
    DateTime? generatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CoachMessage',
      if (id != null) 'id': id,
      'taskId': taskId,
      'coachId': coachId,
      'textContent': textContent,
      if (audioStoragePath != null) 'audioStoragePath': audioStoragePath,
      'generatedAt': generatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CoachMessage',
      if (id != null) 'id': id,
      'taskId': taskId,
      'coachId': coachId,
      'textContent': textContent,
      if (audioStoragePath != null) 'audioStoragePath': audioStoragePath,
      'generatedAt': generatedAt.toJson(),
    };
  }

  static CoachMessageInclude include() {
    return CoachMessageInclude._();
  }

  static CoachMessageIncludeList includeList({
    _i1.WhereExpressionBuilder<CoachMessageTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CoachMessageTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CoachMessageTable>? orderByList,
    CoachMessageInclude? include,
  }) {
    return CoachMessageIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CoachMessage.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(CoachMessage.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CoachMessageImpl extends CoachMessage {
  _CoachMessageImpl({
    int? id,
    required int taskId,
    required int coachId,
    required String textContent,
    String? audioStoragePath,
    required DateTime generatedAt,
  }) : super._(
         id: id,
         taskId: taskId,
         coachId: coachId,
         textContent: textContent,
         audioStoragePath: audioStoragePath,
         generatedAt: generatedAt,
       );

  /// Returns a shallow copy of this [CoachMessage]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CoachMessage copyWith({
    Object? id = _Undefined,
    int? taskId,
    int? coachId,
    String? textContent,
    Object? audioStoragePath = _Undefined,
    DateTime? generatedAt,
  }) {
    return CoachMessage(
      id: id is int? ? id : this.id,
      taskId: taskId ?? this.taskId,
      coachId: coachId ?? this.coachId,
      textContent: textContent ?? this.textContent,
      audioStoragePath: audioStoragePath is String?
          ? audioStoragePath
          : this.audioStoragePath,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }
}

class CoachMessageUpdateTable extends _i1.UpdateTable<CoachMessageTable> {
  CoachMessageUpdateTable(super.table);

  _i1.ColumnValue<int, int> taskId(int value) => _i1.ColumnValue(
    table.taskId,
    value,
  );

  _i1.ColumnValue<int, int> coachId(int value) => _i1.ColumnValue(
    table.coachId,
    value,
  );

  _i1.ColumnValue<String, String> textContent(String value) => _i1.ColumnValue(
    table.textContent,
    value,
  );

  _i1.ColumnValue<String, String> audioStoragePath(String? value) =>
      _i1.ColumnValue(
        table.audioStoragePath,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> generatedAt(DateTime value) =>
      _i1.ColumnValue(
        table.generatedAt,
        value,
      );
}

class CoachMessageTable extends _i1.Table<int?> {
  CoachMessageTable({super.tableRelation}) : super(tableName: 'coach_message') {
    updateTable = CoachMessageUpdateTable(this);
    taskId = _i1.ColumnInt(
      'taskId',
      this,
    );
    coachId = _i1.ColumnInt(
      'coachId',
      this,
    );
    textContent = _i1.ColumnString(
      'textContent',
      this,
    );
    audioStoragePath = _i1.ColumnString(
      'audioStoragePath',
      this,
    );
    generatedAt = _i1.ColumnDateTime(
      'generatedAt',
      this,
    );
  }

  late final CoachMessageUpdateTable updateTable;

  /// Reference to the task this message is about
  late final _i1.ColumnInt taskId;

  /// Reference to the coach who generated this message
  late final _i1.ColumnInt coachId;

  /// The generated text content of the message
  late final _i1.ColumnString textContent;

  /// Path to the stored audio file (MP3)
  late final _i1.ColumnString audioStoragePath;

  /// When this message was generated
  late final _i1.ColumnDateTime generatedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    taskId,
    coachId,
    textContent,
    audioStoragePath,
    generatedAt,
  ];
}

class CoachMessageInclude extends _i1.IncludeObject {
  CoachMessageInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => CoachMessage.t;
}

class CoachMessageIncludeList extends _i1.IncludeList {
  CoachMessageIncludeList._({
    _i1.WhereExpressionBuilder<CoachMessageTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CoachMessage.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => CoachMessage.t;
}

class CoachMessageRepository {
  const CoachMessageRepository._();

  /// Returns a list of [CoachMessage]s matching the given query parameters.
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
  Future<List<CoachMessage>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<CoachMessageTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CoachMessageTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CoachMessageTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<CoachMessage>(
      where: where?.call(CoachMessage.t),
      orderBy: orderBy?.call(CoachMessage.t),
      orderByList: orderByList?.call(CoachMessage.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [CoachMessage] matching the given query parameters.
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
  Future<CoachMessage?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<CoachMessageTable>? where,
    int? offset,
    _i1.OrderByBuilder<CoachMessageTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CoachMessageTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<CoachMessage>(
      where: where?.call(CoachMessage.t),
      orderBy: orderBy?.call(CoachMessage.t),
      orderByList: orderByList?.call(CoachMessage.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [CoachMessage] by its [id] or null if no such row exists.
  Future<CoachMessage?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<CoachMessage>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [CoachMessage]s in the list and returns the inserted rows.
  ///
  /// The returned [CoachMessage]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<CoachMessage>> insert(
    _i1.Session session,
    List<CoachMessage> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<CoachMessage>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [CoachMessage] and returns the inserted row.
  ///
  /// The returned [CoachMessage] will have its `id` field set.
  Future<CoachMessage> insertRow(
    _i1.Session session,
    CoachMessage row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<CoachMessage>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [CoachMessage]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<CoachMessage>> update(
    _i1.Session session,
    List<CoachMessage> rows, {
    _i1.ColumnSelections<CoachMessageTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<CoachMessage>(
      rows,
      columns: columns?.call(CoachMessage.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CoachMessage]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CoachMessage> updateRow(
    _i1.Session session,
    CoachMessage row, {
    _i1.ColumnSelections<CoachMessageTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<CoachMessage>(
      row,
      columns: columns?.call(CoachMessage.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CoachMessage] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CoachMessage?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<CoachMessageUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<CoachMessage>(
      id,
      columnValues: columnValues(CoachMessage.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CoachMessage]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<CoachMessage>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<CoachMessageUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<CoachMessageTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CoachMessageTable>? orderBy,
    _i1.OrderByListBuilder<CoachMessageTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<CoachMessage>(
      columnValues: columnValues(CoachMessage.t.updateTable),
      where: where(CoachMessage.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CoachMessage.t),
      orderByList: orderByList?.call(CoachMessage.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [CoachMessage]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<CoachMessage>> delete(
    _i1.Session session,
    List<CoachMessage> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<CoachMessage>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [CoachMessage].
  Future<CoachMessage> deleteRow(
    _i1.Session session,
    CoachMessage row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CoachMessage>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<CoachMessage>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<CoachMessageTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<CoachMessage>(
      where: where(CoachMessage.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<CoachMessageTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<CoachMessage>(
      where: where?.call(CoachMessage.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
