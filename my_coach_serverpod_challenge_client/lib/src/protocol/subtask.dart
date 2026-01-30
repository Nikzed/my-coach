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

/// Subtask for breaking down tasks into smaller steps
abstract class Subtask implements _i1.SerializableModel {
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

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
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
