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

/// Draft task created from voice input, pending user confirmation
abstract class VoiceTaskDraft implements _i1.SerializableModel {
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

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
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
