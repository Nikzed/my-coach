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

/// Draft task created from voice input, pending user confirmation
abstract class VoiceTaskDraft
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  VoiceTaskDraft._({
    this.id,
    required this.userId,
    required this.sessionId,
    required this.transcribedText,
    this.parsedName,
    this.parsedDescription,
    this.parsedDueTime,
    this.suggestedCoachId,
    this.coachConfidence,
    this.parsedSubtasks,
    this.parsedReminders,
    required this.status,
    this.clarificationQuestion,
    this.conversationHistory,
    required this.createdAt,
    required this.expiresAt,
  });

  factory VoiceTaskDraft({
    int? id,
    required String userId,
    required String sessionId,
    required String transcribedText,
    String? parsedName,
    String? parsedDescription,
    String? parsedDueTime,
    int? suggestedCoachId,
    double? coachConfidence,
    String? parsedSubtasks,
    String? parsedReminders,
    required String status,
    String? clarificationQuestion,
    String? conversationHistory,
    required DateTime createdAt,
    required DateTime expiresAt,
  }) = _VoiceTaskDraftImpl;

  factory VoiceTaskDraft.fromJson(Map<String, dynamic> jsonSerialization) {
    return VoiceTaskDraft(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as String,
      sessionId: jsonSerialization['sessionId'] as String,
      transcribedText: jsonSerialization['transcribedText'] as String,
      parsedName: jsonSerialization['parsedName'] as String?,
      parsedDescription: jsonSerialization['parsedDescription'] as String?,
      parsedDueTime: jsonSerialization['parsedDueTime'] as String?,
      suggestedCoachId: jsonSerialization['suggestedCoachId'] as int?,
      coachConfidence: (jsonSerialization['coachConfidence'] as num?)
          ?.toDouble(),
      parsedSubtasks: jsonSerialization['parsedSubtasks'] as String?,
      parsedReminders: jsonSerialization['parsedReminders'] as String?,
      status: jsonSerialization['status'] as String,
      clarificationQuestion:
          jsonSerialization['clarificationQuestion'] as String?,
      conversationHistory: jsonSerialization['conversationHistory'] as String?,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      expiresAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
    );
  }

  static final t = VoiceTaskDraftTable();

  static const db = VoiceTaskDraftRepository._();

  @override
  int? id;

  /// User who created this draft (serverpod_auth user UUID)
  String userId;

  /// Session ID for conversation continuity
  String sessionId;

  /// Original transcribed text from speech-to-text
  String transcribedText;

  /// AI-parsed task name
  String? parsedName;

  /// AI-parsed task description
  String? parsedDescription;

  /// AI-parsed due time as ISO string
  String? parsedDueTime;

  /// AI-suggested coach ID based on task tone
  int? suggestedCoachId;

  /// Confidence score (0-1) for coach suggestion
  double? coachConfidence;

  /// JSON array of subtask names
  String? parsedSubtasks;

  /// JSON array of minutesBefore values for reminders
  String? parsedReminders;

  /// Status: pending, needs_clarification, confirmed, expired
  String status;

  /// Question to ask user if clarification needed
  String? clarificationQuestion;

  /// JSON array of conversation history for multi-turn clarification
  String? conversationHistory;

  /// When the draft was created
  DateTime createdAt;

  /// When the draft expires (auto-cleanup)
  DateTime expiresAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [VoiceTaskDraft]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  VoiceTaskDraft copyWith({
    int? id,
    String? userId,
    String? sessionId,
    String? transcribedText,
    String? parsedName,
    String? parsedDescription,
    String? parsedDueTime,
    int? suggestedCoachId,
    double? coachConfidence,
    String? parsedSubtasks,
    String? parsedReminders,
    String? status,
    String? clarificationQuestion,
    String? conversationHistory,
    DateTime? createdAt,
    DateTime? expiresAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'VoiceTaskDraft',
      if (id != null) 'id': id,
      'userId': userId,
      'sessionId': sessionId,
      'transcribedText': transcribedText,
      if (parsedName != null) 'parsedName': parsedName,
      if (parsedDescription != null) 'parsedDescription': parsedDescription,
      if (parsedDueTime != null) 'parsedDueTime': parsedDueTime,
      if (suggestedCoachId != null) 'suggestedCoachId': suggestedCoachId,
      if (coachConfidence != null) 'coachConfidence': coachConfidence,
      if (parsedSubtasks != null) 'parsedSubtasks': parsedSubtasks,
      if (parsedReminders != null) 'parsedReminders': parsedReminders,
      'status': status,
      if (clarificationQuestion != null)
        'clarificationQuestion': clarificationQuestion,
      if (conversationHistory != null)
        'conversationHistory': conversationHistory,
      'createdAt': createdAt.toJson(),
      'expiresAt': expiresAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'VoiceTaskDraft',
      if (id != null) 'id': id,
      'userId': userId,
      'sessionId': sessionId,
      'transcribedText': transcribedText,
      if (parsedName != null) 'parsedName': parsedName,
      if (parsedDescription != null) 'parsedDescription': parsedDescription,
      if (parsedDueTime != null) 'parsedDueTime': parsedDueTime,
      if (suggestedCoachId != null) 'suggestedCoachId': suggestedCoachId,
      if (coachConfidence != null) 'coachConfidence': coachConfidence,
      if (parsedSubtasks != null) 'parsedSubtasks': parsedSubtasks,
      if (parsedReminders != null) 'parsedReminders': parsedReminders,
      'status': status,
      if (clarificationQuestion != null)
        'clarificationQuestion': clarificationQuestion,
      if (conversationHistory != null)
        'conversationHistory': conversationHistory,
      'createdAt': createdAt.toJson(),
      'expiresAt': expiresAt.toJson(),
    };
  }

  static VoiceTaskDraftInclude include() {
    return VoiceTaskDraftInclude._();
  }

  static VoiceTaskDraftIncludeList includeList({
    _i1.WhereExpressionBuilder<VoiceTaskDraftTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<VoiceTaskDraftTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<VoiceTaskDraftTable>? orderByList,
    VoiceTaskDraftInclude? include,
  }) {
    return VoiceTaskDraftIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(VoiceTaskDraft.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(VoiceTaskDraft.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _VoiceTaskDraftImpl extends VoiceTaskDraft {
  _VoiceTaskDraftImpl({
    int? id,
    required String userId,
    required String sessionId,
    required String transcribedText,
    String? parsedName,
    String? parsedDescription,
    String? parsedDueTime,
    int? suggestedCoachId,
    double? coachConfidence,
    String? parsedSubtasks,
    String? parsedReminders,
    required String status,
    String? clarificationQuestion,
    String? conversationHistory,
    required DateTime createdAt,
    required DateTime expiresAt,
  }) : super._(
         id: id,
         userId: userId,
         sessionId: sessionId,
         transcribedText: transcribedText,
         parsedName: parsedName,
         parsedDescription: parsedDescription,
         parsedDueTime: parsedDueTime,
         suggestedCoachId: suggestedCoachId,
         coachConfidence: coachConfidence,
         parsedSubtasks: parsedSubtasks,
         parsedReminders: parsedReminders,
         status: status,
         clarificationQuestion: clarificationQuestion,
         conversationHistory: conversationHistory,
         createdAt: createdAt,
         expiresAt: expiresAt,
       );

  /// Returns a shallow copy of this [VoiceTaskDraft]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  VoiceTaskDraft copyWith({
    Object? id = _Undefined,
    String? userId,
    String? sessionId,
    String? transcribedText,
    Object? parsedName = _Undefined,
    Object? parsedDescription = _Undefined,
    Object? parsedDueTime = _Undefined,
    Object? suggestedCoachId = _Undefined,
    Object? coachConfidence = _Undefined,
    Object? parsedSubtasks = _Undefined,
    Object? parsedReminders = _Undefined,
    String? status,
    Object? clarificationQuestion = _Undefined,
    Object? conversationHistory = _Undefined,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return VoiceTaskDraft(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      sessionId: sessionId ?? this.sessionId,
      transcribedText: transcribedText ?? this.transcribedText,
      parsedName: parsedName is String? ? parsedName : this.parsedName,
      parsedDescription: parsedDescription is String?
          ? parsedDescription
          : this.parsedDescription,
      parsedDueTime: parsedDueTime is String?
          ? parsedDueTime
          : this.parsedDueTime,
      suggestedCoachId: suggestedCoachId is int?
          ? suggestedCoachId
          : this.suggestedCoachId,
      coachConfidence: coachConfidence is double?
          ? coachConfidence
          : this.coachConfidence,
      parsedSubtasks: parsedSubtasks is String?
          ? parsedSubtasks
          : this.parsedSubtasks,
      parsedReminders: parsedReminders is String?
          ? parsedReminders
          : this.parsedReminders,
      status: status ?? this.status,
      clarificationQuestion: clarificationQuestion is String?
          ? clarificationQuestion
          : this.clarificationQuestion,
      conversationHistory: conversationHistory is String?
          ? conversationHistory
          : this.conversationHistory,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

class VoiceTaskDraftUpdateTable extends _i1.UpdateTable<VoiceTaskDraftTable> {
  VoiceTaskDraftUpdateTable(super.table);

  _i1.ColumnValue<String, String> userId(String value) => _i1.ColumnValue(
    table.userId,
    value,
  );

  _i1.ColumnValue<String, String> sessionId(String value) => _i1.ColumnValue(
    table.sessionId,
    value,
  );

  _i1.ColumnValue<String, String> transcribedText(String value) =>
      _i1.ColumnValue(
        table.transcribedText,
        value,
      );

  _i1.ColumnValue<String, String> parsedName(String? value) => _i1.ColumnValue(
    table.parsedName,
    value,
  );

  _i1.ColumnValue<String, String> parsedDescription(String? value) =>
      _i1.ColumnValue(
        table.parsedDescription,
        value,
      );

  _i1.ColumnValue<String, String> parsedDueTime(String? value) =>
      _i1.ColumnValue(
        table.parsedDueTime,
        value,
      );

  _i1.ColumnValue<int, int> suggestedCoachId(int? value) => _i1.ColumnValue(
    table.suggestedCoachId,
    value,
  );

  _i1.ColumnValue<double, double> coachConfidence(double? value) =>
      _i1.ColumnValue(
        table.coachConfidence,
        value,
      );

  _i1.ColumnValue<String, String> parsedSubtasks(String? value) =>
      _i1.ColumnValue(
        table.parsedSubtasks,
        value,
      );

  _i1.ColumnValue<String, String> parsedReminders(String? value) =>
      _i1.ColumnValue(
        table.parsedReminders,
        value,
      );

  _i1.ColumnValue<String, String> status(String value) => _i1.ColumnValue(
    table.status,
    value,
  );

  _i1.ColumnValue<String, String> clarificationQuestion(String? value) =>
      _i1.ColumnValue(
        table.clarificationQuestion,
        value,
      );

  _i1.ColumnValue<String, String> conversationHistory(String? value) =>
      _i1.ColumnValue(
        table.conversationHistory,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> expiresAt(DateTime value) =>
      _i1.ColumnValue(
        table.expiresAt,
        value,
      );
}

class VoiceTaskDraftTable extends _i1.Table<int?> {
  VoiceTaskDraftTable({super.tableRelation})
    : super(tableName: 'voice_task_draft') {
    updateTable = VoiceTaskDraftUpdateTable(this);
    userId = _i1.ColumnString(
      'userId',
      this,
    );
    sessionId = _i1.ColumnString(
      'sessionId',
      this,
    );
    transcribedText = _i1.ColumnString(
      'transcribedText',
      this,
    );
    parsedName = _i1.ColumnString(
      'parsedName',
      this,
    );
    parsedDescription = _i1.ColumnString(
      'parsedDescription',
      this,
    );
    parsedDueTime = _i1.ColumnString(
      'parsedDueTime',
      this,
    );
    suggestedCoachId = _i1.ColumnInt(
      'suggestedCoachId',
      this,
    );
    coachConfidence = _i1.ColumnDouble(
      'coachConfidence',
      this,
    );
    parsedSubtasks = _i1.ColumnString(
      'parsedSubtasks',
      this,
    );
    parsedReminders = _i1.ColumnString(
      'parsedReminders',
      this,
    );
    status = _i1.ColumnString(
      'status',
      this,
    );
    clarificationQuestion = _i1.ColumnString(
      'clarificationQuestion',
      this,
    );
    conversationHistory = _i1.ColumnString(
      'conversationHistory',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
    expiresAt = _i1.ColumnDateTime(
      'expiresAt',
      this,
    );
  }

  late final VoiceTaskDraftUpdateTable updateTable;

  /// User who created this draft (serverpod_auth user UUID)
  late final _i1.ColumnString userId;

  /// Session ID for conversation continuity
  late final _i1.ColumnString sessionId;

  /// Original transcribed text from speech-to-text
  late final _i1.ColumnString transcribedText;

  /// AI-parsed task name
  late final _i1.ColumnString parsedName;

  /// AI-parsed task description
  late final _i1.ColumnString parsedDescription;

  /// AI-parsed due time as ISO string
  late final _i1.ColumnString parsedDueTime;

  /// AI-suggested coach ID based on task tone
  late final _i1.ColumnInt suggestedCoachId;

  /// Confidence score (0-1) for coach suggestion
  late final _i1.ColumnDouble coachConfidence;

  /// JSON array of subtask names
  late final _i1.ColumnString parsedSubtasks;

  /// JSON array of minutesBefore values for reminders
  late final _i1.ColumnString parsedReminders;

  /// Status: pending, needs_clarification, confirmed, expired
  late final _i1.ColumnString status;

  /// Question to ask user if clarification needed
  late final _i1.ColumnString clarificationQuestion;

  /// JSON array of conversation history for multi-turn clarification
  late final _i1.ColumnString conversationHistory;

  /// When the draft was created
  late final _i1.ColumnDateTime createdAt;

  /// When the draft expires (auto-cleanup)
  late final _i1.ColumnDateTime expiresAt;

  @override
  List<_i1.Column> get columns => [
    id,
    userId,
    sessionId,
    transcribedText,
    parsedName,
    parsedDescription,
    parsedDueTime,
    suggestedCoachId,
    coachConfidence,
    parsedSubtasks,
    parsedReminders,
    status,
    clarificationQuestion,
    conversationHistory,
    createdAt,
    expiresAt,
  ];
}

class VoiceTaskDraftInclude extends _i1.IncludeObject {
  VoiceTaskDraftInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => VoiceTaskDraft.t;
}

class VoiceTaskDraftIncludeList extends _i1.IncludeList {
  VoiceTaskDraftIncludeList._({
    _i1.WhereExpressionBuilder<VoiceTaskDraftTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(VoiceTaskDraft.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => VoiceTaskDraft.t;
}

class VoiceTaskDraftRepository {
  const VoiceTaskDraftRepository._();

  /// Returns a list of [VoiceTaskDraft]s matching the given query parameters.
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
  Future<List<VoiceTaskDraft>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<VoiceTaskDraftTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<VoiceTaskDraftTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<VoiceTaskDraftTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<VoiceTaskDraft>(
      where: where?.call(VoiceTaskDraft.t),
      orderBy: orderBy?.call(VoiceTaskDraft.t),
      orderByList: orderByList?.call(VoiceTaskDraft.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [VoiceTaskDraft] matching the given query parameters.
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
  Future<VoiceTaskDraft?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<VoiceTaskDraftTable>? where,
    int? offset,
    _i1.OrderByBuilder<VoiceTaskDraftTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<VoiceTaskDraftTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<VoiceTaskDraft>(
      where: where?.call(VoiceTaskDraft.t),
      orderBy: orderBy?.call(VoiceTaskDraft.t),
      orderByList: orderByList?.call(VoiceTaskDraft.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [VoiceTaskDraft] by its [id] or null if no such row exists.
  Future<VoiceTaskDraft?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<VoiceTaskDraft>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [VoiceTaskDraft]s in the list and returns the inserted rows.
  ///
  /// The returned [VoiceTaskDraft]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<VoiceTaskDraft>> insert(
    _i1.Session session,
    List<VoiceTaskDraft> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<VoiceTaskDraft>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [VoiceTaskDraft] and returns the inserted row.
  ///
  /// The returned [VoiceTaskDraft] will have its `id` field set.
  Future<VoiceTaskDraft> insertRow(
    _i1.Session session,
    VoiceTaskDraft row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<VoiceTaskDraft>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [VoiceTaskDraft]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<VoiceTaskDraft>> update(
    _i1.Session session,
    List<VoiceTaskDraft> rows, {
    _i1.ColumnSelections<VoiceTaskDraftTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<VoiceTaskDraft>(
      rows,
      columns: columns?.call(VoiceTaskDraft.t),
      transaction: transaction,
    );
  }

  /// Updates a single [VoiceTaskDraft]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<VoiceTaskDraft> updateRow(
    _i1.Session session,
    VoiceTaskDraft row, {
    _i1.ColumnSelections<VoiceTaskDraftTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<VoiceTaskDraft>(
      row,
      columns: columns?.call(VoiceTaskDraft.t),
      transaction: transaction,
    );
  }

  /// Updates a single [VoiceTaskDraft] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<VoiceTaskDraft?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<VoiceTaskDraftUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<VoiceTaskDraft>(
      id,
      columnValues: columnValues(VoiceTaskDraft.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [VoiceTaskDraft]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<VoiceTaskDraft>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<VoiceTaskDraftUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<VoiceTaskDraftTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<VoiceTaskDraftTable>? orderBy,
    _i1.OrderByListBuilder<VoiceTaskDraftTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<VoiceTaskDraft>(
      columnValues: columnValues(VoiceTaskDraft.t.updateTable),
      where: where(VoiceTaskDraft.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(VoiceTaskDraft.t),
      orderByList: orderByList?.call(VoiceTaskDraft.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [VoiceTaskDraft]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<VoiceTaskDraft>> delete(
    _i1.Session session,
    List<VoiceTaskDraft> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<VoiceTaskDraft>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [VoiceTaskDraft].
  Future<VoiceTaskDraft> deleteRow(
    _i1.Session session,
    VoiceTaskDraft row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<VoiceTaskDraft>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<VoiceTaskDraft>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<VoiceTaskDraftTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<VoiceTaskDraft>(
      where: where(VoiceTaskDraft.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<VoiceTaskDraftTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<VoiceTaskDraft>(
      where: where?.call(VoiceTaskDraft.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
