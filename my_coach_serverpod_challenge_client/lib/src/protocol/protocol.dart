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
import 'coach.dart' as _i2;
import 'coach_message.dart' as _i3;
import 'greetings/greeting.dart' as _i4;
import 'subtask.dart' as _i5;
import 'task.dart' as _i6;
import 'task_reminder.dart' as _i7;
import 'user_device.dart' as _i8;
import 'voice_task_draft.dart' as _i9;
import 'package:my_coach_serverpod_challenge_client/src/protocol/coach_message.dart'
    as _i10;
import 'package:my_coach_serverpod_challenge_client/src/protocol/coach.dart'
    as _i11;
import 'package:my_coach_serverpod_challenge_client/src/protocol/task_reminder.dart'
    as _i12;
import 'package:my_coach_serverpod_challenge_client/src/protocol/subtask.dart'
    as _i13;
import 'package:my_coach_serverpod_challenge_client/src/protocol/task.dart'
    as _i14;
import 'package:my_coach_serverpod_challenge_client/src/protocol/voice_task_draft.dart'
    as _i15;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i16;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i17;
export 'coach.dart';
export 'coach_message.dart';
export 'greetings/greeting.dart';
export 'subtask.dart';
export 'task.dart';
export 'task_reminder.dart';
export 'user_device.dart';
export 'voice_task_draft.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on FormatException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i2.Coach) {
      return _i2.Coach.fromJson(data) as T;
    }
    if (t == _i3.CoachMessage) {
      return _i3.CoachMessage.fromJson(data) as T;
    }
    if (t == _i4.Greeting) {
      return _i4.Greeting.fromJson(data) as T;
    }
    if (t == _i5.Subtask) {
      return _i5.Subtask.fromJson(data) as T;
    }
    if (t == _i6.Task) {
      return _i6.Task.fromJson(data) as T;
    }
    if (t == _i7.TaskReminder) {
      return _i7.TaskReminder.fromJson(data) as T;
    }
    if (t == _i8.UserDevice) {
      return _i8.UserDevice.fromJson(data) as T;
    }
    if (t == _i9.VoiceTaskDraft) {
      return _i9.VoiceTaskDraft.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.Coach?>()) {
      return (data != null ? _i2.Coach.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.CoachMessage?>()) {
      return (data != null ? _i3.CoachMessage.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.Greeting?>()) {
      return (data != null ? _i4.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.Subtask?>()) {
      return (data != null ? _i5.Subtask.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.Task?>()) {
      return (data != null ? _i6.Task.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.TaskReminder?>()) {
      return (data != null ? _i7.TaskReminder.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.UserDevice?>()) {
      return (data != null ? _i8.UserDevice.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.VoiceTaskDraft?>()) {
      return (data != null ? _i9.VoiceTaskDraft.fromJson(data) : null) as T;
    }
    if (t == List<_i10.CoachMessage>) {
      return (data as List)
              .map((e) => deserialize<_i10.CoachMessage>(e))
              .toList()
          as T;
    }
    if (t == List<_i11.Coach>) {
      return (data as List).map((e) => deserialize<_i11.Coach>(e)).toList()
          as T;
    }
    if (t == List<_i12.TaskReminder>) {
      return (data as List)
              .map((e) => deserialize<_i12.TaskReminder>(e))
              .toList()
          as T;
    }
    if (t == List<_i13.Subtask>) {
      return (data as List).map((e) => deserialize<_i13.Subtask>(e)).toList()
          as T;
    }
    if (t == List<int>) {
      return (data as List).map((e) => deserialize<int>(e)).toList() as T;
    }
    if (t == _i1.getType<List<int>?>()) {
      return (data != null
              ? (data as List).map((e) => deserialize<int>(e)).toList()
              : null)
          as T;
    }
    if (t == List<_i14.Task>) {
      return (data as List).map((e) => deserialize<_i14.Task>(e)).toList() as T;
    }
    if (t == List<_i15.VoiceTaskDraft>) {
      return (data as List)
              .map((e) => deserialize<_i15.VoiceTaskDraft>(e))
              .toList()
          as T;
    }
    try {
      return _i16.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i17.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.Coach => 'Coach',
      _i3.CoachMessage => 'CoachMessage',
      _i4.Greeting => 'Greeting',
      _i5.Subtask => 'Subtask',
      _i6.Task => 'Task',
      _i7.TaskReminder => 'TaskReminder',
      _i8.UserDevice => 'UserDevice',
      _i9.VoiceTaskDraft => 'VoiceTaskDraft',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst(
        'my_coach_serverpod_challenge.',
        '',
      );
    }

    switch (data) {
      case _i2.Coach():
        return 'Coach';
      case _i3.CoachMessage():
        return 'CoachMessage';
      case _i4.Greeting():
        return 'Greeting';
      case _i5.Subtask():
        return 'Subtask';
      case _i6.Task():
        return 'Task';
      case _i7.TaskReminder():
        return 'TaskReminder';
      case _i8.UserDevice():
        return 'UserDevice';
      case _i9.VoiceTaskDraft():
        return 'VoiceTaskDraft';
    }
    className = _i16.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i17.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_core.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'Coach') {
      return deserialize<_i2.Coach>(data['data']);
    }
    if (dataClassName == 'CoachMessage') {
      return deserialize<_i3.CoachMessage>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i4.Greeting>(data['data']);
    }
    if (dataClassName == 'Subtask') {
      return deserialize<_i5.Subtask>(data['data']);
    }
    if (dataClassName == 'Task') {
      return deserialize<_i6.Task>(data['data']);
    }
    if (dataClassName == 'TaskReminder') {
      return deserialize<_i7.TaskReminder>(data['data']);
    }
    if (dataClassName == 'UserDevice') {
      return deserialize<_i8.UserDevice>(data['data']);
    }
    if (dataClassName == 'VoiceTaskDraft') {
      return deserialize<_i9.VoiceTaskDraft>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i16.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i17.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _i16.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i17.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
