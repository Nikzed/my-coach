import 'dart:convert';

import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';

/// Service for sending push notifications via Firebase Cloud Messaging.
/// Uses FCM HTTP v1 API with OAuth2 authentication.
class FCMService {
  final String _projectId;
  final auth.ServiceAccountCredentials _credentials;
  final http.Client _httpClient;
  auth.AccessToken? _cachedToken;

  FCMService({
    required String projectId,
    required auth.ServiceAccountCredentials credentials,
    http.Client? httpClient,
  })  : _projectId = projectId,
        _credentials = credentials,
        _httpClient = httpClient ?? http.Client();

  /// Factory constructor to create FCMService from Serverpod session.
  /// Requires fcmServiceAccount (JSON string) and fcmProjectId in passwords.yaml
  factory FCMService.fromSession(Session session) {
    final serviceAccountJson = session.passwords['fcmServiceAccount'];
    final projectId = session.passwords['fcmProjectId'];
    
    if (serviceAccountJson == null || serviceAccountJson.isEmpty) {
      throw StateError(
        'FCM service account JSON not configured in passwords.yaml. '
        'Add fcmServiceAccount with the contents of your Firebase service account JSON file.',
      );
    }
    
    if (projectId == null || projectId.isEmpty) {
      throw StateError(
        'FCM project ID not configured in passwords.yaml. '
        'Add fcmProjectId with your Firebase project ID.',
      );
    }

    try {
      final Map<String, dynamic> serviceAccount = jsonDecode(serviceAccountJson);
      final credentials = auth.ServiceAccountCredentials.fromJson(serviceAccount);
      return FCMService(
        projectId: projectId,
        credentials: credentials,
      );
    } catch (e) {
      throw StateError('Failed to parse FCM service account JSON: $e');
    }
  }

  /// Gets a valid access token, refreshing if necessary.
  Future<String> _getAccessToken() async {
    // Check if we have a cached token that's still valid (with 5 min buffer)
    if (_cachedToken != null && 
        _cachedToken!.expiry.isAfter(DateTime.now().add(const Duration(minutes: 5)))) {
      return _cachedToken!.data;
    }

    // Get a new token
    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
    final client = await auth.clientViaServiceAccount(_credentials, scopes);
    _cachedToken = client.credentials.accessToken;
    client.close();

    return _cachedToken!.data;
  }

  /// Builds the FCM v1 API endpoint URL.
  String get _fcmV1Url => 'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send';

  /// Sends a high-priority data message to trigger the call UI on the client.
  ///
  /// [fcmToken] - The device's FCM token
  /// [messageId] - The coach message ID for audio retrieval
  /// [coachName] - The coach's name to display on the call UI
  /// [taskId] - The task ID for context
  /// [taskName] - The task name for context
  /// [audioUrl] - URL to retrieve the audio file
  Future<bool> sendCoachCallNotification({
    required String fcmToken,
    required int messageId,
    required String coachName,
    required int taskId,
    required String taskName,
    required String audioUrl,
  }) async {
    final accessToken = await _getAccessToken();

    // FCM v1 API message format
    // Note: Keys use snake_case to match client-side expectations
    final payload = {
      'message': {
        'token': fcmToken,
        'data': {
          'type': 'coach_call',
          'message_id': messageId.toString(),
          'coach_name': coachName,
          'task_id': taskId.toString(),
          'task_name': taskName,
          'audio_url': audioUrl,
          'timestamp': DateTime.now().toIso8601String(),
        },
        'notification': {
          'title': 'Incoming Call from $coachName',
          'body': 'About: $taskName',
        },
        'android': {
          'priority': 'HIGH',
          'notification': {
            'sound': 'ringtone',
            'channel_id': 'coach_calls',
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          },
        },
        'apns': {
          'headers': {
            'apns-priority': '10',
          },
          'payload': {
            'aps': {
              'alert': {
                'title': 'Incoming Call from $coachName',
                'body': 'About: $taskName',
              },
              'sound': 'ringtone.caf',
              'content-available': 1,
              'mutable-content': 1,
            },
          },
        },
      },
    };

    final response = await _httpClient.post(
      Uri.parse(_fcmV1Url),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      // Log error but return false instead of throwing for consistent handling
      // Common errors: 404 = invalid token, 400 = malformed request
      return false;
    }

    // v1 API returns success if status is 200
    return true;
  }

  /// Sends a simple notification (non-call).
  Future<bool> sendNotification({
    required String fcmToken,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    final accessToken = await _getAccessToken();

    final payload = {
      'message': {
        'token': fcmToken,
        'notification': {
          'title': title,
          'body': body,
        },
        'android': {
          'priority': 'HIGH',
          'notification': {
            'sound': 'default',
          },
        },
        'apns': {
          'payload': {
            'aps': {
              'sound': 'default',
            },
          },
        },
        if (data != null) 'data': data,
      },
    };

    final response = await _httpClient.post(
      Uri.parse(_fcmV1Url),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      return false;
    }

    return true;
  }

  /// Closes the HTTP client.
  void dispose() {
    _httpClient.close();
  }
}
