import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';

import 'call_service.dart';

/// Centralized state manager for call navigation.
/// Replaces the scattered flags in main.dart and call_service.dart.
enum CallNavigationState {
  /// No active call, ready for new incoming calls
  idle,

  /// Checking for pending accepted calls (e.g., after background accept)
  checkingPending,

  /// Showing incoming call screen
  showingIncoming,

  /// Navigating to call screen (accepted call)
  navigatingToCall,

  /// Currently in an active call
  inCall,
}

/// Manages the navigation state for incoming calls.
/// Provides a single source of truth for call-related navigation decisions.
class CallStateManager extends ChangeNotifier {
  CallNavigationState _state = CallNavigationState.idle;
  CallData? _activeCallData;

  CallNavigationState get state => _state;
  CallData? get activeCallData => _activeCallData;

  /// Whether we can show a new incoming call screen
  bool get canShowIncomingCall =>
      _state == CallNavigationState.idle &&
      _activeCallData == null;

  /// Whether we can navigate to call screen
  bool get canNavigateToCall =>
      _state != CallNavigationState.inCall &&
      _state != CallNavigationState.navigatingToCall;

  /// Whether we're currently checking for pending calls
  bool get isCheckingForPending =>
      _state == CallNavigationState.checkingPending;

  /// Start checking for pending accepted calls.
  /// Call this during app startup and when returning from background.
  void beginCheckingForPending() {
    if (_state == CallNavigationState.inCall) return;
    _state = CallNavigationState.checkingPending;
    notifyListeners();
  }

  /// Finished checking for pending calls, no pending call found.
  void finishCheckingForPending() {
    if (_state == CallNavigationState.checkingPending) {
      _state = CallNavigationState.idle;
      notifyListeners();
    }
  }

  /// Begin navigation to call screen with the given call data.
  void beginNavigation(CallData data) {
    _state = CallNavigationState.navigatingToCall;
    _activeCallData = data;
    notifyListeners();
  }

  /// Call screen is now active.
  void enterCall() {
    _state = CallNavigationState.inCall;
    notifyListeners();
  }

  /// Show incoming call screen.
  void showIncoming(CallData data) {
    if (!canShowIncomingCall) {
      debugPrint('CallStateManager: Cannot show incoming - state: $_state');
      return;
    }
    _state = CallNavigationState.showingIncoming;
    _activeCallData = data;
    notifyListeners();
  }

  /// Call ended - reset to idle state.
  void endCall() {
    debugPrint('CallStateManager: Call ended, resetting to idle');
    _state = CallNavigationState.idle;
    _activeCallData = null;
    notifyListeners();
  }

  /// Check for any pending accepted calls.
  /// Returns CallData if a pending call was found, null otherwise.
  /// This consolidates the 3-level fallback logic from main.dart.
  Future<CallData?> checkForPendingCall() async {
    beginCheckingForPending();

    try {
      // 1. In-memory pending field (same engine, set during this run)
      final inMemory = CallService.instance.consumePendingAcceptedCall();
      if (inMemory != null) {
        debugPrint('CallStateManager: Found in-memory pending call');
        return inMemory;
      }

      // 2. SharedPreferences - persisted by background FCM handler
      final persisted = await CallService.loadPersistedIncomingCall();
      if (persisted != null) {
        debugPrint('CallStateManager: Found persisted pending call');
        return persisted;
      }

      // 3. Fallback: check native activeCalls list
      final activeCalls = await FlutterCallkitIncoming.activeCalls();
      if (activeCalls is List && activeCalls.isNotEmpty) {
        final callData = activeCalls.first;
        if (callData is Map<String, dynamic>) {
          final parsed = _parseCallKitData(callData);
          if (parsed != null) {
            debugPrint('CallStateManager: Found active CallKit call');
            return parsed;
          }
        }
      }

      // No pending call found
      finishCheckingForPending();
      return null;
    } catch (e) {
      debugPrint('CallStateManager: Error checking for pending call: $e');
      finishCheckingForPending();
      return null;
    }
  }

  /// Parse CallKit call data map into CallData object.
  CallData? _parseCallKitData(Map<String, dynamic> callData) {
    final extra = callData['extra'] as Map<String, dynamic>?;
    if (extra == null) return null;

    final coachName = extra['coach_name']?.toString();
    final messageIdStr = extra['message_id']?.toString();
    final taskIdStr = extra['task_id']?.toString();

    if (coachName == null || messageIdStr == null) return null;

    final messageId = int.tryParse(messageIdStr);
    if (messageId == null) return null;

    return CallData(
      callId: callData['id']?.toString() ?? '',
      coachName: coachName,
      messageId: messageId,
      taskId: int.tryParse(taskIdStr ?? '0') ?? 0,
      taskName: extra['task_name']?.toString(),
      receivedAt: DateTime.now(),
    );
  }
}
