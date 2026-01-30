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

/// AI-generated coach message with audio
abstract class CoachMessage implements _i1.SerializableModel {
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

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
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
