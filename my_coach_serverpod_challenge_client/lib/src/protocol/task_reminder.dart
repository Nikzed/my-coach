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

/// Individual reminder for a task (Google Calendar style - multiple reminders per task)
abstract class TaskReminder implements _i1.SerializableModel {
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

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// Reference to the parent task
  int taskId;

  /// Minutes before due time to send reminder (0 = at due time, 30 = 30 min before, 1440 = 1 day before)
  int minutesBefore;

  /// Whether this reminder has been sent
  bool isSent;

  /// When the reminder was sent
  DateTime? sentAt;

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
