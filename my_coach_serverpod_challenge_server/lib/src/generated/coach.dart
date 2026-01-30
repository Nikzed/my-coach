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

/// Coach character model for AI coaching personas
abstract class Coach implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  Coach._({
    this.id,
    required this.name,
    required this.description,
    required this.personalityPrompt,
    required this.elevenLabsVoiceId,
    this.elevenLabsModelId,
    this.voiceStability,
    this.voiceSimilarity,
    this.voiceStyle,
    this.voiceSpeed,
    this.useSpeakerBoost,
  });

  factory Coach({
    int? id,
    required String name,
    required String description,
    required String personalityPrompt,
    required String elevenLabsVoiceId,
    String? elevenLabsModelId,
    double? voiceStability,
    double? voiceSimilarity,
    double? voiceStyle,
    double? voiceSpeed,
    bool? useSpeakerBoost,
  }) = _CoachImpl;

  factory Coach.fromJson(Map<String, dynamic> jsonSerialization) {
    return Coach(
      id: jsonSerialization['id'] as int?,
      name: jsonSerialization['name'] as String,
      description: jsonSerialization['description'] as String,
      personalityPrompt: jsonSerialization['personalityPrompt'] as String,
      elevenLabsVoiceId: jsonSerialization['elevenLabsVoiceId'] as String,
      elevenLabsModelId: jsonSerialization['elevenLabsModelId'] as String?,
      voiceStability: (jsonSerialization['voiceStability'] as num?)?.toDouble(),
      voiceSimilarity: (jsonSerialization['voiceSimilarity'] as num?)
          ?.toDouble(),
      voiceStyle: (jsonSerialization['voiceStyle'] as num?)?.toDouble(),
      voiceSpeed: (jsonSerialization['voiceSpeed'] as num?)?.toDouble(),
      useSpeakerBoost: jsonSerialization['useSpeakerBoost'] as bool?,
    );
  }

  static final t = CoachTable();

  static const db = CoachRepository._();

  @override
  int? id;

  /// The name of the coach character (e.g., "Sergeant", "Melly")
  String name;

  /// A brief description of the coach's personality
  String description;

  /// System prompt for Grok LLM defining the coach's personality
  String personalityPrompt;

  /// ElevenLabs voice ID for text-to-speech
  String elevenLabsVoiceId;

  /// ElevenLabs model ID (e.g., eleven_multilingual_v2, eleven_v3)
  String? elevenLabsModelId;

  /// Voice stability setting (0.0-1.0)
  double? voiceStability;

  /// Voice similarity boost setting (0.0-1.0)
  double? voiceSimilarity;

  /// Voice style setting (0.0-1.0)
  double? voiceStyle;

  /// Voice speed setting (0.5-2.0)
  double? voiceSpeed;

  /// Whether to use speaker boost
  bool? useSpeakerBoost;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [Coach]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Coach copyWith({
    int? id,
    String? name,
    String? description,
    String? personalityPrompt,
    String? elevenLabsVoiceId,
    String? elevenLabsModelId,
    double? voiceStability,
    double? voiceSimilarity,
    double? voiceStyle,
    double? voiceSpeed,
    bool? useSpeakerBoost,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Coach',
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'personalityPrompt': personalityPrompt,
      'elevenLabsVoiceId': elevenLabsVoiceId,
      if (elevenLabsModelId != null) 'elevenLabsModelId': elevenLabsModelId,
      if (voiceStability != null) 'voiceStability': voiceStability,
      if (voiceSimilarity != null) 'voiceSimilarity': voiceSimilarity,
      if (voiceStyle != null) 'voiceStyle': voiceStyle,
      if (voiceSpeed != null) 'voiceSpeed': voiceSpeed,
      if (useSpeakerBoost != null) 'useSpeakerBoost': useSpeakerBoost,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Coach',
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'personalityPrompt': personalityPrompt,
      'elevenLabsVoiceId': elevenLabsVoiceId,
      if (elevenLabsModelId != null) 'elevenLabsModelId': elevenLabsModelId,
      if (voiceStability != null) 'voiceStability': voiceStability,
      if (voiceSimilarity != null) 'voiceSimilarity': voiceSimilarity,
      if (voiceStyle != null) 'voiceStyle': voiceStyle,
      if (voiceSpeed != null) 'voiceSpeed': voiceSpeed,
      if (useSpeakerBoost != null) 'useSpeakerBoost': useSpeakerBoost,
    };
  }

  static CoachInclude include() {
    return CoachInclude._();
  }

  static CoachIncludeList includeList({
    _i1.WhereExpressionBuilder<CoachTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CoachTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CoachTable>? orderByList,
    CoachInclude? include,
  }) {
    return CoachIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Coach.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Coach.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CoachImpl extends Coach {
  _CoachImpl({
    int? id,
    required String name,
    required String description,
    required String personalityPrompt,
    required String elevenLabsVoiceId,
    String? elevenLabsModelId,
    double? voiceStability,
    double? voiceSimilarity,
    double? voiceStyle,
    double? voiceSpeed,
    bool? useSpeakerBoost,
  }) : super._(
         id: id,
         name: name,
         description: description,
         personalityPrompt: personalityPrompt,
         elevenLabsVoiceId: elevenLabsVoiceId,
         elevenLabsModelId: elevenLabsModelId,
         voiceStability: voiceStability,
         voiceSimilarity: voiceSimilarity,
         voiceStyle: voiceStyle,
         voiceSpeed: voiceSpeed,
         useSpeakerBoost: useSpeakerBoost,
       );

  /// Returns a shallow copy of this [Coach]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Coach copyWith({
    Object? id = _Undefined,
    String? name,
    String? description,
    String? personalityPrompt,
    String? elevenLabsVoiceId,
    Object? elevenLabsModelId = _Undefined,
    Object? voiceStability = _Undefined,
    Object? voiceSimilarity = _Undefined,
    Object? voiceStyle = _Undefined,
    Object? voiceSpeed = _Undefined,
    Object? useSpeakerBoost = _Undefined,
  }) {
    return Coach(
      id: id is int? ? id : this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      personalityPrompt: personalityPrompt ?? this.personalityPrompt,
      elevenLabsVoiceId: elevenLabsVoiceId ?? this.elevenLabsVoiceId,
      elevenLabsModelId: elevenLabsModelId is String?
          ? elevenLabsModelId
          : this.elevenLabsModelId,
      voiceStability: voiceStability is double?
          ? voiceStability
          : this.voiceStability,
      voiceSimilarity: voiceSimilarity is double?
          ? voiceSimilarity
          : this.voiceSimilarity,
      voiceStyle: voiceStyle is double? ? voiceStyle : this.voiceStyle,
      voiceSpeed: voiceSpeed is double? ? voiceSpeed : this.voiceSpeed,
      useSpeakerBoost: useSpeakerBoost is bool?
          ? useSpeakerBoost
          : this.useSpeakerBoost,
    );
  }
}

class CoachUpdateTable extends _i1.UpdateTable<CoachTable> {
  CoachUpdateTable(super.table);

  _i1.ColumnValue<String, String> name(String value) => _i1.ColumnValue(
    table.name,
    value,
  );

  _i1.ColumnValue<String, String> description(String value) => _i1.ColumnValue(
    table.description,
    value,
  );

  _i1.ColumnValue<String, String> personalityPrompt(String value) =>
      _i1.ColumnValue(
        table.personalityPrompt,
        value,
      );

  _i1.ColumnValue<String, String> elevenLabsVoiceId(String value) =>
      _i1.ColumnValue(
        table.elevenLabsVoiceId,
        value,
      );

  _i1.ColumnValue<String, String> elevenLabsModelId(String? value) =>
      _i1.ColumnValue(
        table.elevenLabsModelId,
        value,
      );

  _i1.ColumnValue<double, double> voiceStability(double? value) =>
      _i1.ColumnValue(
        table.voiceStability,
        value,
      );

  _i1.ColumnValue<double, double> voiceSimilarity(double? value) =>
      _i1.ColumnValue(
        table.voiceSimilarity,
        value,
      );

  _i1.ColumnValue<double, double> voiceStyle(double? value) => _i1.ColumnValue(
    table.voiceStyle,
    value,
  );

  _i1.ColumnValue<double, double> voiceSpeed(double? value) => _i1.ColumnValue(
    table.voiceSpeed,
    value,
  );

  _i1.ColumnValue<bool, bool> useSpeakerBoost(bool? value) => _i1.ColumnValue(
    table.useSpeakerBoost,
    value,
  );
}

class CoachTable extends _i1.Table<int?> {
  CoachTable({super.tableRelation}) : super(tableName: 'coach') {
    updateTable = CoachUpdateTable(this);
    name = _i1.ColumnString(
      'name',
      this,
    );
    description = _i1.ColumnString(
      'description',
      this,
    );
    personalityPrompt = _i1.ColumnString(
      'personalityPrompt',
      this,
    );
    elevenLabsVoiceId = _i1.ColumnString(
      'elevenLabsVoiceId',
      this,
    );
    elevenLabsModelId = _i1.ColumnString(
      'elevenLabsModelId',
      this,
    );
    voiceStability = _i1.ColumnDouble(
      'voiceStability',
      this,
    );
    voiceSimilarity = _i1.ColumnDouble(
      'voiceSimilarity',
      this,
    );
    voiceStyle = _i1.ColumnDouble(
      'voiceStyle',
      this,
    );
    voiceSpeed = _i1.ColumnDouble(
      'voiceSpeed',
      this,
    );
    useSpeakerBoost = _i1.ColumnBool(
      'useSpeakerBoost',
      this,
    );
  }

  late final CoachUpdateTable updateTable;

  /// The name of the coach character (e.g., "Sergeant", "Melly")
  late final _i1.ColumnString name;

  /// A brief description of the coach's personality
  late final _i1.ColumnString description;

  /// System prompt for Grok LLM defining the coach's personality
  late final _i1.ColumnString personalityPrompt;

  /// ElevenLabs voice ID for text-to-speech
  late final _i1.ColumnString elevenLabsVoiceId;

  /// ElevenLabs model ID (e.g., eleven_multilingual_v2, eleven_v3)
  late final _i1.ColumnString elevenLabsModelId;

  /// Voice stability setting (0.0-1.0)
  late final _i1.ColumnDouble voiceStability;

  /// Voice similarity boost setting (0.0-1.0)
  late final _i1.ColumnDouble voiceSimilarity;

  /// Voice style setting (0.0-1.0)
  late final _i1.ColumnDouble voiceStyle;

  /// Voice speed setting (0.5-2.0)
  late final _i1.ColumnDouble voiceSpeed;

  /// Whether to use speaker boost
  late final _i1.ColumnBool useSpeakerBoost;

  @override
  List<_i1.Column> get columns => [
    id,
    name,
    description,
    personalityPrompt,
    elevenLabsVoiceId,
    elevenLabsModelId,
    voiceStability,
    voiceSimilarity,
    voiceStyle,
    voiceSpeed,
    useSpeakerBoost,
  ];
}

class CoachInclude extends _i1.IncludeObject {
  CoachInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => Coach.t;
}

class CoachIncludeList extends _i1.IncludeList {
  CoachIncludeList._({
    _i1.WhereExpressionBuilder<CoachTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Coach.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => Coach.t;
}

class CoachRepository {
  const CoachRepository._();

  /// Returns a list of [Coach]s matching the given query parameters.
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
  Future<List<Coach>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<CoachTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CoachTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CoachTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<Coach>(
      where: where?.call(Coach.t),
      orderBy: orderBy?.call(Coach.t),
      orderByList: orderByList?.call(Coach.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [Coach] matching the given query parameters.
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
  Future<Coach?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<CoachTable>? where,
    int? offset,
    _i1.OrderByBuilder<CoachTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CoachTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<Coach>(
      where: where?.call(Coach.t),
      orderBy: orderBy?.call(Coach.t),
      orderByList: orderByList?.call(Coach.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [Coach] by its [id] or null if no such row exists.
  Future<Coach?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<Coach>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [Coach]s in the list and returns the inserted rows.
  ///
  /// The returned [Coach]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<Coach>> insert(
    _i1.Session session,
    List<Coach> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<Coach>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [Coach] and returns the inserted row.
  ///
  /// The returned [Coach] will have its `id` field set.
  Future<Coach> insertRow(
    _i1.Session session,
    Coach row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Coach>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Coach]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Coach>> update(
    _i1.Session session,
    List<Coach> rows, {
    _i1.ColumnSelections<CoachTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Coach>(
      rows,
      columns: columns?.call(Coach.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Coach]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Coach> updateRow(
    _i1.Session session,
    Coach row, {
    _i1.ColumnSelections<CoachTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Coach>(
      row,
      columns: columns?.call(Coach.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Coach] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Coach?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<CoachUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<Coach>(
      id,
      columnValues: columnValues(Coach.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Coach]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<Coach>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<CoachUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<CoachTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CoachTable>? orderBy,
    _i1.OrderByListBuilder<CoachTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<Coach>(
      columnValues: columnValues(Coach.t.updateTable),
      where: where(Coach.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Coach.t),
      orderByList: orderByList?.call(Coach.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [Coach]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Coach>> delete(
    _i1.Session session,
    List<Coach> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Coach>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Coach].
  Future<Coach> deleteRow(
    _i1.Session session,
    Coach row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Coach>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Coach>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<CoachTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Coach>(
      where: where(Coach.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<CoachTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Coach>(
      where: where?.call(Coach.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
