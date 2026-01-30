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

/// User task with optional due time for AI coach reminders
abstract class Task implements _i1.SerializableModel {
  Task._({
    this.id,
    required this.userId,
    this.coachId,
    required this.name,
    this.description,
    this.dueTime,
    required this.isCompleted,
    this.completedAt,
    required this.createdAt,
  });

  factory Task({
    int? id,
    required String userId,
    int? coachId,
    required String name,
    String? description,
    DateTime? dueTime,
    required bool isCompleted,
    DateTime? completedAt,
    required DateTime createdAt,
  }) = _TaskImpl;

  factory Task.fromJson(Map<String, dynamic> jsonSerialization) {
    return Task(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as String,
      coachId: jsonSerialization['coachId'] as int?,
      name: jsonSerialization['name'] as String,
      description: jsonSerialization['description'] as String?,
      dueTime: jsonSerialization['dueTime'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['dueTime']),
      isCompleted: jsonSerialization['isCompleted'] as bool,
      completedAt: jsonSerialization['completedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['completedAt'],
            ),
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// Reference to the user who owns this task (serverpod_auth user UUID)
  String userId;

  /// Reference to the coach character assigned to this task (optional - no coach means no reminders)
  int? coachId;

  /// The name/title of the task
  String name;

  /// Optional detailed description of the task
  String? description;

  /// Optional due time - tasks without this won't trigger reminders
  DateTime? dueTime;

  /// Whether the task has been completed
  bool isCompleted;

  /// When the task was marked as completed
  DateTime? completedAt;

  /// When the task was created
  DateTime createdAt;

  /// Returns a shallow copy of this [Task]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Task copyWith({
    int? id,
    String? userId,
    int? coachId,
    String? name,
    String? description,
    DateTime? dueTime,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Task',
      if (id != null) 'id': id,
      'userId': userId,
      if (coachId != null) 'coachId': coachId,
      'name': name,
      if (description != null) 'description': description,
      if (dueTime != null) 'dueTime': dueTime?.toJson(),
      'isCompleted': isCompleted,
      if (completedAt != null) 'completedAt': completedAt?.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TaskImpl extends Task {
  _TaskImpl({
    int? id,
    required String userId,
    int? coachId,
    required String name,
    String? description,
    DateTime? dueTime,
    required bool isCompleted,
    DateTime? completedAt,
    required DateTime createdAt,
  }) : super._(
         id: id,
         userId: userId,
         coachId: coachId,
         name: name,
         description: description,
         dueTime: dueTime,
         isCompleted: isCompleted,
         completedAt: completedAt,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Task]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Task copyWith({
    Object? id = _Undefined,
    String? userId,
    Object? coachId = _Undefined,
    String? name,
    Object? description = _Undefined,
    Object? dueTime = _Undefined,
    bool? isCompleted,
    Object? completedAt = _Undefined,
    DateTime? createdAt,
  }) {
    return Task(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      coachId: coachId is int? ? coachId : this.coachId,
      name: name ?? this.name,
      description: description is String? ? description : this.description,
      dueTime: dueTime is DateTime? ? dueTime : this.dueTime,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt is DateTime? ? completedAt : this.completedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
