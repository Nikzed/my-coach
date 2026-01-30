import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart' as callkit_entities;
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../firebase_options.dart';
import '../main.dart';

/// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('CallService: Handling background message: ${message.messageId}');

  final data = message.data;
  if (data['type'] == 'coach_call') {
    // Show the CallKit notification first. Only persist if successful.
    // This prevents stale data from being saved when a call is ignored
    // (e.g., because another call is already active).
    final shown = await CallService.instance._showCallKitIncoming(data);
    if (shown) {
      // Persist after showing — guaranteed to finish since background
      // handler runs to completion. If user later accepts and Android
      // restarts the activity, the new engine reads this data.
      await CallService.persistIncomingCallData(data);
      debugPrint('CallService: Persisted incoming call data');
    }
  }
}

/// Represents the data for an incoming coach call
class CallData {
  final String callId;
  final String coachName;
  final int messageId;
  final int taskId;
  final String? taskName;
  final DateTime receivedAt;

  const CallData({
    required this.callId,
    required this.coachName,
    required this.messageId,
    required this.taskId,
    this.taskName,
    required this.receivedAt,
  });

  CallData copyWith({
    String? callId,
    String? coachName,
    int? messageId,
    int? taskId,
    String? taskName,
    DateTime? receivedAt,
  }) {
    return CallData(
      callId: callId ?? this.callId,
      coachName: coachName ?? this.coachName,
      messageId: messageId ?? this.messageId,
      taskId: taskId ?? this.taskId,
      taskName: taskName ?? this.taskName,
      receivedAt: receivedAt ?? this.receivedAt,
    );
  }

  @override
  String toString() => 'CallData(callId: $callId, coachName: $coachName, '
      'messageId: $messageId, taskId: $taskId, taskName: $taskName)';
}

/// Represents different call events that can occur
sealed class CallEvent {
  const CallEvent();
}

class CallEventIncoming extends CallEvent {
  final CallData data;
  const CallEventIncoming(this.data);
}

class CallEventAccepted extends CallEvent {
  final CallData data;
  const CallEventAccepted(this.data);
}

class CallEventDeclined extends CallEvent {
  final CallData data;
  const CallEventDeclined(this.data);
}

class CallEventEnded extends CallEvent {
  final CallData data;
  const CallEventEnded(this.data);
}

class CallEventMissed extends CallEvent {
  final CallData data;
  const CallEventMissed(this.data);
}

/// Service for handling incoming coach calls via FCM and CallKit.
///
/// This service manages the complete call lifecycle:
/// 1. Receives FCM push notification with call data
/// 2. Shows native CallKit UI for incoming call
/// 3. Handles user actions (accept/decline)
/// 4. Emits events for the app to navigate accordingly
class CallService {
  CallService._();
  static final CallService instance = CallService._();

  static const _incomingCallKey = 'incoming_call_data';

  late final FirebaseMessaging _messaging;
  final _uuid = const Uuid();

  // Event stream for call events
  final StreamController<CallEvent> _eventController =
      StreamController<CallEvent>.broadcast();
  Stream<CallEvent> get events => _eventController.stream;

  // Track current call to prevent duplicates
  CallData? _currentCall;
  CallData? get currentCall => _currentCall;

  // Stores an accepted call that has not yet been consumed by the UI.
  // Bridges the gap between CallKit firing actionCallAccept during
  // main() initialization and the UI listener being set up after runApp().
  CallData? _pendingAcceptedCall;
  CallData? get pendingAcceptedCall => _pendingAcceptedCall;

  /// Consume and clear the pending accepted call.
  /// Returns the call data if one was pending, null otherwise.
  CallData? consumePendingAcceptedCall() {
    final call = _pendingAcceptedCall;
    _pendingAcceptedCall = null;
    return call;
  }

  /// Mark a call as active. This prevents new incoming call notifications
  /// from being shown while a call is in progress.
  /// Call this when navigating to CallScreen after loading from persisted data
  /// (engine restart scenario where _currentCall is not set).
  void setActiveCall(CallData callData) {
    _currentCall = callData;
    debugPrint('CallService: Set active call: ${callData.callId}');
  }

  /// Persist incoming call data to SharedPreferences.
  /// Called from the background FCM handler, which is guaranteed to
  /// run to completion. This data survives engine restarts and lets
  /// the new engine navigate to CallScreen after a background accept.
  static Future<void> persistIncomingCallData(
      Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode({
        'coach_name': data['coach_name'],
        'message_id': data['message_id'],
        'task_id': data['task_id'],
        'task_name': data['task_name'],
        'persisted_at': DateTime.now().toIso8601String(),
      });
      await prefs.setString(_incomingCallKey, json);
      debugPrint('CallService: Persisted incoming call data');
    } catch (e) {
      debugPrint(
          'CallService: Failed to persist incoming call data: $e');
    }
  }

  /// Load persisted incoming call data (without clearing it).
  /// Returns CallData if recent data exists, null otherwise.
  /// Call clearPersistedIncomingCall() from CallScreen after it's displayed.
  static Future<CallData?> loadPersistedIncomingCall() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_incomingCallKey);
      debugPrint('CallService: loadPersistedIncomingCall raw=$raw');
      if (raw == null) return null;

      // DON'T clear here - let CallScreen clear it after displaying.
      // If we clear too early and Android restarts the activity,
      // the new engine won't find the pending call data.

      final map = jsonDecode(raw) as Map<String, dynamic>;
      final persistedAt = DateTime.tryParse(
        map['persisted_at'] as String? ?? '',
      );

      // Discard calls older than 2 minutes — they are stale.
      if (persistedAt != null &&
          DateTime.now().difference(persistedAt).inMinutes > 2) {
        return null;
      }

      final coachName = map['coach_name']?.toString();
      final messageIdStr = map['message_id']?.toString();
      if (coachName == null || messageIdStr == null) return null;

      final messageId = int.tryParse(messageIdStr);
      if (messageId == null) return null;

      return CallData(
        callId: const Uuid().v4(),
        coachName: coachName,
        messageId: messageId,
        taskId:
            int.tryParse(map['task_id']?.toString() ?? '0') ?? 0,
        taskName: map['task_name']?.toString(),
        receivedAt: persistedAt ?? DateTime.now(),
      );
    } catch (e) {
      debugPrint(
          'CallService: Failed to load persisted incoming call: $e');
      return null;
    }
  }

  /// Clear persisted incoming call data.
  static Future<void> clearPersistedIncomingCall() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_incomingCallKey);
    } catch (e) {
      debugPrint(
          'CallService: Failed to clear persisted incoming call: '
          '$e');
    }
  }

  /// Check if persisted incoming call data exists (without consuming it).
  /// Used to prevent showing IncomingCallScreen after a background accept
  /// when the engine has restarted and in-memory state is lost.
  static Future<bool> hasPersistedIncomingCall() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_incomingCallKey);
      if (raw == null) return false;

      final map = jsonDecode(raw) as Map<String, dynamic>;
      final persistedAt = DateTime.tryParse(
        map['persisted_at'] as String? ?? '',
      );

      // Discard calls older than 2 minutes — they are stale.
      if (persistedAt != null &&
          DateTime.now().difference(persistedAt).inMinutes > 2) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  bool _isInitialized = false;

  /// Initialize the call service. Must be called before using any other methods.
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('CallService: Already initialized');
      return;
    }

    try {
      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Initialize messaging after Firebase is ready
      _messaging = FirebaseMessaging.instance;

      await _messaging.setAutoInitEnabled(true);

      // Request notification permissions
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: false,
        criticalAlert: true,
        provisional: false,
        sound: true,
      );

      debugPrint('CallService: Permission status: ${settings.authorizationStatus}');

      // Set up Firebase message handlers
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // Check for initial message (app opened from notification)
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageOpenedApp(initialMessage);
      }

      // Set up CallKit event handlers
      _setupCallKitListeners();

      _isInitialized = true;
      debugPrint('CallService: Initialized successfully');
    } catch (e) {
      debugPrint('CallService: Initialization failed: $e');
      rethrow;
    }
  }

  /// Get the FCM token for device registration
  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      debugPrint('CallService: Failed to get FCM token: $e');
      return null;
    }
  }

  /// Register this device with the backend for push notifications
  Future<bool> registerDevice() async {
    try {
      final token = await getToken();
      if (token == null) {
        debugPrint('CallService: Cannot register - no FCM token');
        return false;
      }

      final platform = Platform.isAndroid ? 'android' : 'ios';
      await client.device.registerDevice(token, platform);
      debugPrint('CallService: Device registered successfully');
      return true;
    } catch (e) {
      debugPrint('CallService: Failed to register device: $e');
      return false;
    }
  }

  /// Unregister this device from the backend
  Future<bool> unregisterDevice() async {
    try {
      await client.device.unregisterDevice();
      debugPrint('CallService: Device unregistered successfully');
      return true;
    } catch (e) {
      debugPrint('CallService: Failed to unregister device: $e');
      return false;
    }
  }

  /// End the current call
  Future<void> endCall() async {
    debugPrint('CallService: endCall() called, _currentCall=$_currentCall');
    // End all native CallKit calls to ensure no orphaned notifications
    await FlutterCallkitIncoming.endAllCalls();
    _pendingAcceptedCall = null;
    clearPersistedIncomingCall();
    if (_currentCall != null) {
      final endedCall = _currentCall!;
      _currentCall = null;
      debugPrint('CallService: endCall() - cleared _currentCall');
      _eventController.add(CallEventEnded(endedCall));
    }
  }

  /// End all active calls
  Future<void> endAllCalls() async {
    await FlutterCallkitIncoming.endAllCalls();
    _pendingAcceptedCall = null;
    clearPersistedIncomingCall();
    if (_currentCall != null) {
      final endedCall = _currentCall!;
      _currentCall = null;
      _eventController.add(CallEventEnded(endedCall));
    }
  }

  void _setupCallKitListeners() {
    FlutterCallkitIncoming.onEvent.listen((callkit_entities.CallEvent? event) {
      if (event == null) return;

      debugPrint('CallService: CallKit event: ${event.event}');

      switch (event.event) {
        case callkit_entities.Event.actionCallAccept:
          _handleCallAccepted(event.body);
          break;
        case callkit_entities.Event.actionCallDecline:
          _handleCallDeclined(event.body);
          break;
        case callkit_entities.Event.actionCallEnded:
          _handleCallEnded(event.body);
          break;
        case callkit_entities.Event.actionCallTimeout:
          _handleCallTimeout(event.body);
          break;
        default:
          debugPrint('CallService: Unhandled CallKit event: ${event.event}');
          break;
      }
    });
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('CallService: Foreground message received');
    final data = message.data;

    if (data['type'] == 'coach_call') {
      // In the foreground, show only the custom IncomingCallScreen
      // (via the event stream). Skip the native CallKit notification
      // to avoid duplicate UI.
      await _showForegroundIncomingCall(data);
    }
  }

  /// Show an incoming call using only the in-app UI.
  /// Used when the app is in the foreground to avoid the native CallKit
  /// notification duplicating the custom IncomingCallScreen.
  Future<void> _showForegroundIncomingCall(Map<String, dynamic> data) async {
    debugPrint('CallService: _showForegroundIncomingCall called');
    debugPrint('CallService: _currentCall=$_currentCall, _pendingAcceptedCall=$_pendingAcceptedCall');

    if (_currentCall != null) {
      debugPrint(
          'CallService: Ignoring incoming call — already have active call');
      return;
    }

    // Don't show incoming call if we have a pending accepted call
    // (happens when app returns to foreground after accepting from native UI)
    if (_pendingAcceptedCall != null) {
      debugPrint(
          'CallService: Ignoring incoming call — '
          'already have pending accepted call');
      return;
    }

    // Check for persisted call data — indicates we're processing an
    // accepted call from a previous engine that restarted after background
    // accept. The in-memory state is lost on restart, so we check disk.
    final hasPersisted = await hasPersistedIncomingCall();
    debugPrint('CallService: hasPersistedIncomingCall=$hasPersisted');
    if (hasPersisted) {
      debugPrint(
          'CallService: Ignoring foreground incoming call — '
          'found persisted call data (background accept in progress)');
      return;
    }

    final callId = _uuid.v4();
    final callData = _parseCallData(data, callId);

    if (callData == null) {
      debugPrint('CallService: Invalid call data received');
      return;
    }

    _currentCall = callData;
    _eventController.add(CallEventIncoming(callData));
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('CallService: App opened from message');
    final data = message.data;

    if (data['type'] == 'coach_call') {
      // App was opened by tapping the notification - treat as accepted
      final callData = _parseCallData(data, _uuid.v4());
      if (callData != null) {
        _currentCall = callData;
        _eventController.add(CallEventAccepted(callData));
      }
    }
  }

  /// Shows the native CallKit incoming call notification.
  /// Returns true if the notification was shown, false if ignored.
  Future<bool> _showCallKitIncoming(Map<String, dynamic> data) async {
    // Check native CallKit for active calls (more reliable than _currentCall
    // because background isolate may be reused with stale in-memory state)
    final activeCalls = await FlutterCallkitIncoming.activeCalls();
    if (activeCalls is List && activeCalls.isNotEmpty) {
      debugPrint('CallService: Ignoring incoming call - native CallKit has active call');
      return false;
    }

    final callId = _uuid.v4();
    final callData = _parseCallData(data, callId);

    if (callData == null) {
      debugPrint('CallService: Invalid call data received');
      return false;
    }

    // NOTE: Don't set _currentCall here. This method runs in background isolate
    // which can be reused, causing stale state. The main isolate sets _currentCall
    // when handling CallKit events via setActiveCall().

    final params = callkit_entities.CallKitParams(
      id: callId,
      nameCaller: 'Coach ${callData.coachName}',
      appName: 'MyCoach',
      avatar: null,
      handle: callData.taskName ?? 'Missed deadline!',
      type: 0, // Audio call
      textAccept: 'Answer',
      textDecline: 'Ignore',
      duration: 45000, // 45 seconds ring duration
      extra: {
        'coach_name': callData.coachName,
        'message_id': callData.messageId.toString(),
        'task_id': callData.taskId.toString(),
        'task_name': callData.taskName ?? '',
      },
      android: const callkit_entities.AndroidParams(
        isCustomNotification: true,
        isShowLogo: false,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#0D0D0F',
        actionColor: '#D4A574',
        textColor: '#F5F5F5',
        incomingCallNotificationChannelName: 'Coach Calls',
        missedCallNotificationChannelName: 'Missed Coach Calls',
        isShowCallID: false,
      ),
      ios: const callkit_entities.IOSParams(
        iconName: 'CallKitLogo',
        handleType: 'generic',
        supportsVideo: false,
        maximumCallGroups: 2,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'default',
        audioSessionActive: true,
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
        supportsDTMF: false,
        supportsHolding: false,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtonePath: 'system_ringtone_default',
      ),
    );

    await FlutterCallkitIncoming.showCallkitIncoming(params);
    _eventController.add(CallEventIncoming(callData));
    return true;
  }

  CallData? _parseCallData(Map<String, dynamic> data, String callId) {
    try {
      final coachName = data['coach_name']?.toString();
      final messageIdStr = data['message_id']?.toString();
      final taskIdStr = data['task_id']?.toString();

      if (coachName == null || messageIdStr == null) {
        return null;
      }

      final messageId = int.tryParse(messageIdStr);
      final taskId = int.tryParse(taskIdStr ?? '0') ?? 0;

      if (messageId == null) {
        return null;
      }

      return CallData(
        callId: callId,
        coachName: coachName,
        messageId: messageId,
        taskId: taskId,
        taskName: data['task_name']?.toString(),
        receivedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('CallService: Failed to parse call data: $e');
      return null;
    }
  }

  void _handleCallAccepted(Map<String, dynamic>? body) {
    if (body == null) return;

    // When the app was in background, the background handler ran in a
    // separate isolate so _currentCall is null in the main isolate.
    // Reconstruct CallData from the CallKit event body extras.
    if (_currentCall == null) {
      debugPrint('CallService: _currentCall is null, '
          'reconstructing from CallKit body');
      final rawExtra = body['extra'];
      if (rawExtra == null) return;
      // CallKit returns extra as Map<Object?, Object?>
      final extra = Map<String, dynamic>.from(rawExtra as Map);

      final callId = body['id']?.toString() ?? _uuid.v4();
      final coachName = extra['coach_name']?.toString();
      final messageIdStr = extra['message_id']?.toString();
      final taskIdStr = extra['task_id']?.toString();

      if (coachName == null || messageIdStr == null) return;

      final messageId = int.tryParse(messageIdStr);
      if (messageId == null) return;

      _currentCall = CallData(
        callId: callId,
        coachName: coachName,
        messageId: messageId,
        taskId: int.tryParse(taskIdStr ?? '0') ?? 0,
        taskName: extra['task_name']?.toString(),
        receivedAt: DateTime.now(),
      );
    }

    debugPrint('CallService: Call accepted');

    // Store as pending so the UI can pick it up even if the stream
    // listener isn't subscribed yet (happens when app restarts from
    // background — events emitted before runApp() are lost on a
    // broadcast stream).
    _pendingAcceptedCall = _currentCall;

    // No need to persist here — the background FCM handler already
    // persisted incoming call data to SharedPreferences before
    // showing the CallKit notification. That data survives engine
    // restarts.

    // Do NOT call FlutterCallkitIncoming.endCall() here.
    // The native UI will be dismissed by the navigation helper in
    // main.dart once it's ready to show CallScreen.
    _eventController.add(CallEventAccepted(_currentCall!));
  }

  void _handleCallDeclined(Map<String, dynamic>? body) {
    if (_currentCall == null) return;

    debugPrint('CallService: Call declined');
    clearPersistedIncomingCall();
    final declinedCall = _currentCall!;
    _currentCall = null;
    _eventController.add(CallEventDeclined(declinedCall));
  }

  void _handleCallEnded(Map<String, dynamic>? body) {
    // If there is a pending accepted call, the native CallKit UI is
    // dismissing itself but we still need the call data for navigation.
    // Don't clear it — the UI will consume it.
    if (_pendingAcceptedCall != null) {
      debugPrint('CallService: Ignoring callEnded — '
          'pending accepted call exists');
      return;
    }

    if (_currentCall == null) return;

    debugPrint('CallService: Call ended');
    final endedCall = _currentCall!;
    _currentCall = null;
    _eventController.add(CallEventEnded(endedCall));
  }

  void _handleCallTimeout(Map<String, dynamic>? body) {
    if (_currentCall == null) return;

    debugPrint('CallService: Call timed out (missed)');
    clearPersistedIncomingCall();
    final missedCall = _currentCall!;
    _currentCall = null;
    _eventController.add(CallEventMissed(missedCall));
  }

  /// Dispose of the service and clean up resources
  void dispose() {
    _eventController.close();
    _currentCall = null;
    _isInitialized = false;
  }
}
