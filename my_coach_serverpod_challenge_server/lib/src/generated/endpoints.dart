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
import '../audio/audio_endpoint.dart' as _i2;
import '../auth/google_idp_endpoint.dart' as _i3;
import '../auth/jwt_refresh_endpoint.dart' as _i4;
import '../coaches/coach_endpoint.dart' as _i5;
import '../devices/device_endpoint.dart' as _i6;
import '../greetings/greeting_endpoint.dart' as _i7;
import '../reminders/task_reminder_endpoint.dart' as _i8;
import '../subtasks/subtask_endpoint.dart' as _i9;
import '../tasks/task_endpoint.dart' as _i10;
import '../voice_input/voice_input_endpoint.dart' as _i11;
import 'package:my_coach_serverpod_challenge_server/src/generated/task.dart'
    as _i12;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _i13;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i14;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'audio': _i2.AudioEndpoint()
        ..initialize(
          server,
          'audio',
          null,
        ),
      'googleIdp': _i3.GoogleIdpEndpoint()
        ..initialize(
          server,
          'googleIdp',
          null,
        ),
      'jwtRefresh': _i4.JwtRefreshEndpoint()
        ..initialize(
          server,
          'jwtRefresh',
          null,
        ),
      'coach': _i5.CoachEndpoint()
        ..initialize(
          server,
          'coach',
          null,
        ),
      'device': _i6.DeviceEndpoint()
        ..initialize(
          server,
          'device',
          null,
        ),
      'greeting': _i7.GreetingEndpoint()
        ..initialize(
          server,
          'greeting',
          null,
        ),
      'taskReminder': _i8.TaskReminderEndpoint()
        ..initialize(
          server,
          'taskReminder',
          null,
        ),
      'subtask': _i9.SubtaskEndpoint()
        ..initialize(
          server,
          'subtask',
          null,
        ),
      'task': _i10.TaskEndpoint()
        ..initialize(
          server,
          'task',
          null,
        ),
      'voiceInput': _i11.VoiceInputEndpoint()
        ..initialize(
          server,
          'voiceInput',
          null,
        ),
    };
    connectors['audio'] = _i1.EndpointConnector(
      name: 'audio',
      endpoint: endpoints['audio']!,
      methodConnectors: {
        'getAudio': _i1.MethodConnector(
          name: 'getAudio',
          params: {
            'messageId': _i1.ParameterDescription(
              name: 'messageId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['audio'] as _i2.AudioEndpoint).getAudio(
                session,
                params['messageId'],
              ),
        ),
        'getMessage': _i1.MethodConnector(
          name: 'getMessage',
          params: {
            'messageId': _i1.ParameterDescription(
              name: 'messageId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['audio'] as _i2.AudioEndpoint).getMessage(
                session,
                params['messageId'],
              ),
        ),
        'getMessagesForTask': _i1.MethodConnector(
          name: 'getMessagesForTask',
          params: {
            'taskId': _i1.ParameterDescription(
              name: 'taskId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['audio'] as _i2.AudioEndpoint).getMessagesForTask(
                    session,
                    params['taskId'],
                  ),
        ),
      },
    );
    connectors['googleIdp'] = _i1.EndpointConnector(
      name: 'googleIdp',
      endpoint: endpoints['googleIdp']!,
      methodConnectors: {
        'login': _i1.MethodConnector(
          name: 'login',
          params: {
            'idToken': _i1.ParameterDescription(
              name: 'idToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'accessToken': _i1.ParameterDescription(
              name: 'accessToken',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['googleIdp'] as _i3.GoogleIdpEndpoint).login(
                    session,
                    idToken: params['idToken'],
                    accessToken: params['accessToken'],
                  ),
        ),
      },
    );
    connectors['jwtRefresh'] = _i1.EndpointConnector(
      name: 'jwtRefresh',
      endpoint: endpoints['jwtRefresh']!,
      methodConnectors: {
        'refreshAccessToken': _i1.MethodConnector(
          name: 'refreshAccessToken',
          params: {
            'refreshToken': _i1.ParameterDescription(
              name: 'refreshToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['jwtRefresh'] as _i4.JwtRefreshEndpoint)
                  .refreshAccessToken(
                    session,
                    refreshToken: params['refreshToken'],
                  ),
        ),
      },
    );
    connectors['coach'] = _i1.EndpointConnector(
      name: 'coach',
      endpoint: endpoints['coach']!,
      methodConnectors: {
        'getCoaches': _i1.MethodConnector(
          name: 'getCoaches',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['coach'] as _i5.CoachEndpoint).getCoaches(session),
        ),
        'getCoach': _i1.MethodConnector(
          name: 'getCoach',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['coach'] as _i5.CoachEndpoint).getCoach(
                session,
                params['id'],
              ),
        ),
      },
    );
    connectors['device'] = _i1.EndpointConnector(
      name: 'device',
      endpoint: endpoints['device']!,
      methodConnectors: {
        'registerDevice': _i1.MethodConnector(
          name: 'registerDevice',
          params: {
            'fcmToken': _i1.ParameterDescription(
              name: 'fcmToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'platform': _i1.ParameterDescription(
              name: 'platform',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['device'] as _i6.DeviceEndpoint).registerDevice(
                    session,
                    params['fcmToken'],
                    params['platform'],
                  ),
        ),
        'unregisterDevice': _i1.MethodConnector(
          name: 'unregisterDevice',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['device'] as _i6.DeviceEndpoint)
                  .unregisterDevice(session),
        ),
      },
    );
    connectors['greeting'] = _i1.EndpointConnector(
      name: 'greeting',
      endpoint: endpoints['greeting']!,
      methodConnectors: {
        'hello': _i1.MethodConnector(
          name: 'hello',
          params: {
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['greeting'] as _i7.GreetingEndpoint).hello(
                session,
                params['name'],
              ),
        ),
      },
    );
    connectors['taskReminder'] = _i1.EndpointConnector(
      name: 'taskReminder',
      endpoint: endpoints['taskReminder']!,
      methodConnectors: {
        'getReminders': _i1.MethodConnector(
          name: 'getReminders',
          params: {
            'taskId': _i1.ParameterDescription(
              name: 'taskId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['taskReminder'] as _i8.TaskReminderEndpoint)
                  .getReminders(
                    session,
                    params['taskId'],
                  ),
        ),
        'addReminder': _i1.MethodConnector(
          name: 'addReminder',
          params: {
            'taskId': _i1.ParameterDescription(
              name: 'taskId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'minutesBefore': _i1.ParameterDescription(
              name: 'minutesBefore',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['taskReminder'] as _i8.TaskReminderEndpoint)
                  .addReminder(
                    session,
                    params['taskId'],
                    params['minutesBefore'],
                  ),
        ),
        'removeReminder': _i1.MethodConnector(
          name: 'removeReminder',
          params: {
            'reminderId': _i1.ParameterDescription(
              name: 'reminderId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['taskReminder'] as _i8.TaskReminderEndpoint)
                  .removeReminder(
                    session,
                    params['reminderId'],
                  ),
        ),
        'updateReminder': _i1.MethodConnector(
          name: 'updateReminder',
          params: {
            'reminderId': _i1.ParameterDescription(
              name: 'reminderId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'minutesBefore': _i1.ParameterDescription(
              name: 'minutesBefore',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['taskReminder'] as _i8.TaskReminderEndpoint)
                  .updateReminder(
                    session,
                    params['reminderId'],
                    params['minutesBefore'],
                  ),
        ),
        'addDefaultReminders': _i1.MethodConnector(
          name: 'addDefaultReminders',
          params: {
            'taskId': _i1.ParameterDescription(
              name: 'taskId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['taskReminder'] as _i8.TaskReminderEndpoint)
                  .addDefaultReminders(
                    session,
                    params['taskId'],
                  ),
        ),
        'removeAllReminders': _i1.MethodConnector(
          name: 'removeAllReminders',
          params: {
            'taskId': _i1.ParameterDescription(
              name: 'taskId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['taskReminder'] as _i8.TaskReminderEndpoint)
                  .removeAllReminders(
                    session,
                    params['taskId'],
                  ),
        ),
      },
    );
    connectors['subtask'] = _i1.EndpointConnector(
      name: 'subtask',
      endpoint: endpoints['subtask']!,
      methodConnectors: {
        'getSubtasks': _i1.MethodConnector(
          name: 'getSubtasks',
          params: {
            'taskId': _i1.ParameterDescription(
              name: 'taskId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['subtask'] as _i9.SubtaskEndpoint).getSubtasks(
                    session,
                    params['taskId'],
                  ),
        ),
        'completeSubtask': _i1.MethodConnector(
          name: 'completeSubtask',
          params: {
            'subtaskId': _i1.ParameterDescription(
              name: 'subtaskId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['subtask'] as _i9.SubtaskEndpoint).completeSubtask(
                    session,
                    params['subtaskId'],
                  ),
        ),
        'uncompleteSubtask': _i1.MethodConnector(
          name: 'uncompleteSubtask',
          params: {
            'subtaskId': _i1.ParameterDescription(
              name: 'subtaskId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['subtask'] as _i9.SubtaskEndpoint)
                  .uncompleteSubtask(
                    session,
                    params['subtaskId'],
                  ),
        ),
        'addSubtask': _i1.MethodConnector(
          name: 'addSubtask',
          params: {
            'taskId': _i1.ParameterDescription(
              name: 'taskId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['subtask'] as _i9.SubtaskEndpoint).addSubtask(
                    session,
                    params['taskId'],
                    params['name'],
                  ),
        ),
        'updateSubtask': _i1.MethodConnector(
          name: 'updateSubtask',
          params: {
            'subtaskId': _i1.ParameterDescription(
              name: 'subtaskId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['subtask'] as _i9.SubtaskEndpoint).updateSubtask(
                    session,
                    params['subtaskId'],
                    params['name'],
                  ),
        ),
        'deleteSubtask': _i1.MethodConnector(
          name: 'deleteSubtask',
          params: {
            'subtaskId': _i1.ParameterDescription(
              name: 'subtaskId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['subtask'] as _i9.SubtaskEndpoint).deleteSubtask(
                    session,
                    params['subtaskId'],
                  ),
        ),
        'reorderSubtasks': _i1.MethodConnector(
          name: 'reorderSubtasks',
          params: {
            'subtaskIds': _i1.ParameterDescription(
              name: 'subtaskIds',
              type: _i1.getType<List<int>>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['subtask'] as _i9.SubtaskEndpoint).reorderSubtasks(
                    session,
                    params['subtaskIds'],
                  ),
        ),
      },
    );
    connectors['task'] = _i1.EndpointConnector(
      name: 'task',
      endpoint: endpoints['task']!,
      methodConnectors: {
        'createTask': _i1.MethodConnector(
          name: 'createTask',
          params: {
            'task': _i1.ParameterDescription(
              name: 'task',
              type: _i1.getType<_i12.Task>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['task'] as _i10.TaskEndpoint).createTask(
                session,
                params['task'],
              ),
        ),
        'createTaskWithReminders': _i1.MethodConnector(
          name: 'createTaskWithReminders',
          params: {
            'task': _i1.ParameterDescription(
              name: 'task',
              type: _i1.getType<_i12.Task>(),
              nullable: false,
            ),
            'reminderMinutes': _i1.ParameterDescription(
              name: 'reminderMinutes',
              type: _i1.getType<List<int>?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['task'] as _i10.TaskEndpoint)
                  .createTaskWithReminders(
                    session,
                    params['task'],
                    params['reminderMinutes'],
                  ),
        ),
        'updateTask': _i1.MethodConnector(
          name: 'updateTask',
          params: {
            'task': _i1.ParameterDescription(
              name: 'task',
              type: _i1.getType<_i12.Task>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['task'] as _i10.TaskEndpoint).updateTask(
                session,
                params['task'],
              ),
        ),
        'deleteTask': _i1.MethodConnector(
          name: 'deleteTask',
          params: {
            'taskId': _i1.ParameterDescription(
              name: 'taskId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['task'] as _i10.TaskEndpoint).deleteTask(
                session,
                params['taskId'],
              ),
        ),
        'completeTask': _i1.MethodConnector(
          name: 'completeTask',
          params: {
            'taskId': _i1.ParameterDescription(
              name: 'taskId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['task'] as _i10.TaskEndpoint).completeTask(
                session,
                params['taskId'],
              ),
        ),
        'getUserTasks': _i1.MethodConnector(
          name: 'getUserTasks',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['task'] as _i10.TaskEndpoint).getUserTasks(
                session,
              ),
        ),
        'getPendingTasks': _i1.MethodConnector(
          name: 'getPendingTasks',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['task'] as _i10.TaskEndpoint)
                  .getPendingTasks(session),
        ),
        'uncompleteTask': _i1.MethodConnector(
          name: 'uncompleteTask',
          params: {
            'taskId': _i1.ParameterDescription(
              name: 'taskId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['task'] as _i10.TaskEndpoint).uncompleteTask(
                    session,
                    params['taskId'],
                  ),
        ),
      },
    );
    connectors['voiceInput'] = _i1.EndpointConnector(
      name: 'voiceInput',
      endpoint: endpoints['voiceInput']!,
      methodConnectors: {
        'parseVoiceInput': _i1.MethodConnector(
          name: 'parseVoiceInput',
          params: {
            'transcribedText': _i1.ParameterDescription(
              name: 'transcribedText',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'sessionId': _i1.ParameterDescription(
              name: 'sessionId',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['voiceInput'] as _i11.VoiceInputEndpoint)
                  .parseVoiceInput(
                    session,
                    params['transcribedText'],
                    sessionId: params['sessionId'],
                  ),
        ),
        'confirmDraft': _i1.MethodConnector(
          name: 'confirmDraft',
          params: {
            'draftId': _i1.ParameterDescription(
              name: 'draftId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'overrideCoachId': _i1.ParameterDescription(
              name: 'overrideCoachId',
              type: _i1.getType<int?>(),
              nullable: true,
            ),
            'overrideReminders': _i1.ParameterDescription(
              name: 'overrideReminders',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['voiceInput'] as _i11.VoiceInputEndpoint)
                  .confirmDraft(
                    session,
                    params['draftId'],
                    overrideCoachId: params['overrideCoachId'],
                    overrideReminders: params['overrideReminders'],
                  ),
        ),
        'discardDraft': _i1.MethodConnector(
          name: 'discardDraft',
          params: {
            'draftId': _i1.ParameterDescription(
              name: 'draftId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['voiceInput'] as _i11.VoiceInputEndpoint)
                  .discardDraft(
                    session,
                    params['draftId'],
                  ),
        ),
        'getPendingDrafts': _i1.MethodConnector(
          name: 'getPendingDrafts',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['voiceInput'] as _i11.VoiceInputEndpoint)
                  .getPendingDrafts(session),
        ),
      },
    );
    modules['serverpod_auth_idp'] = _i13.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_core'] = _i14.Endpoints()
      ..initializeEndpoints(server);
  }
}
