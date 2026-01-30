# CallKit Integration - How It Works

This document explains the incoming call flow in the My Coach app, including the critical Android activity restart scenario that required careful handling.

## Overview

The app receives "coach calls" via Firebase Cloud Messaging (FCM) push notifications. When a call arrives, we show a native phone-like UI using `flutter_callkit_incoming`, and when the user accepts, we navigate to `CallScreen` to play the audio message.

## The Challenge: Android Activity Restart

The most complex scenario is when the user accepts a call **from the background** via the native CallKit UI. Here's what happens:

1. App is in background (or killed)
2. FCM message arrives, handled by background isolate
3. Native CallKit notification appears
4. User taps "Accept" on the native UI
5. **Android restarts the Flutter activity** (this is Android's behavior)
6. A completely new Flutter engine starts from scratch
7. The new engine needs to know it should show `CallScreen`, not the home screen

The problem: When Android restarts the activity, all in-memory state is lost. The new Flutter engine has no idea a call was just accepted.

## The Solution: Three-Level Persistence

We use three mechanisms to detect pending calls, checked in order:

### 1. In-Memory Pending Call (`_pendingAcceptedCall`)

```
Location: CallService._pendingAcceptedCall
```

When CallKit's `actionCallAccept` event fires, we store the call data in memory. This works when the app is in foreground and the same Flutter engine handles the accept.

### 2. SharedPreferences Persistence

```
Location: SharedPreferences key "incoming_call_data"
```

The **background FCM handler** persists call data to SharedPreferences BEFORE showing the CallKit notification. This data survives activity restarts.

```dart
// In firebaseMessagingBackgroundHandler:
await CallService.persistIncomingCallData(data);  // Persist FIRST
await CallService._showCallKitIncoming(data);      // Then show UI
```

### 3. Native CallKit Active Calls List

```
Location: FlutterCallkitIncoming.activeCalls()
```

Fallback check of the native CallKit's active calls list.

## Critical Timing: When to Clear Persisted Data

**The Bug We Fixed:**

Previously, we cleared the persisted data in `_navigateToCallScreen()` - right when navigation started:

```dart
// OLD CODE (buggy):
void _navigateToCallScreen(CallData callData) {
  // ...
  CallService.clearPersistedIncomingCall();  // TOO EARLY!
  navigator.pushAndRemoveUntil(...);
}
```

The problem: Android might restart the activity AFTER we clear the data but BEFORE `CallScreen` is displayed. The new engine would find nothing.

**The Fix:**

Only clear persisted data when `CallScreen.initState()` runs - proving the screen is actually displayed:

```dart
// NEW CODE (fixed):
// In main.dart - DON'T clear here
void _navigateToCallScreen(CallData callData) {
  // ...
  // NO clearing of persisted data
  navigator.pushAndRemoveUntil(...);
}

// In call_screen.dart - Clear here
void initState() {
  super.initState();
  CallService.clearPersistedIncomingCall();  // Safe to clear now
  // ...
}
```

## State Management: CallStateManager

`CallStateManager` centralizes navigation state decisions:

```dart
enum CallNavigationState {
  idle,              // Ready for new calls
  checkingPending,   // Checking for pending accepted calls
  showingIncoming,   // Showing IncomingCallScreen
  navigatingToCall,  // Navigating to CallScreen
  inCall,            // Currently in CallScreen
}
```

This prevents race conditions like:
- Showing `IncomingCallScreen` while already navigating to `CallScreen`
- Double-navigation from multiple event sources

## Complete Call Flow Diagrams

### Scenario 1: Foreground Call

```
FCM Message (foreground)
    │
    ▼
CallService._handleForegroundMessage()
    │
    ▼
Emit CallEventIncoming
    │
    ▼
main.dart receives event
    │
    ▼
Show IncomingCallScreen (custom Flutter UI, not native CallKit)
    │
    ▼
User taps Accept
    │
    ▼
Navigate to CallScreen
    │
    ▼
CallScreen.initState() clears persisted data
    │
    ▼
Audio plays
```

### Scenario 2: Background Call (The Complex One)

```
FCM Message (background)
    │
    ▼
firebaseMessagingBackgroundHandler() [separate isolate]
    │
    ├──▶ persistIncomingCallData() to SharedPreferences
    │
    ▼
_showCallKitIncoming() - Native phone UI appears
    │
    ▼
User taps Accept on native UI
    │
    ▼
Android RESTARTS the activity (kills old engine, starts new one)
    │
    ▼
New Flutter engine starts
    │
    ▼
main() runs, MyCoachApp created
    │
    ▼
_MyCoachAppState.initState()
    │
    ├──▶ _listenForCallEvents() - subscribes to CallService events
    │
    ▼
Post-frame callback: _checkForPendingAcceptedCall()
    │
    ▼
CallStateManager.checkForPendingCall()
    │
    ├──▶ Check 1: consumePendingAcceptedCall() → null (new engine)
    │
    ├──▶ Check 2: loadPersistedIncomingCall() → FOUND! ✓
    │
    ▼
_navigateToCallScreen(persistedCallData)
    │
    ▼
CallScreen displayed
    │
    ▼
CallScreen.initState() clears persisted data
    │
    ▼
Audio plays
```

## Key Files

| File | Purpose |
|------|---------|
| `lib/services/call_service.dart` | FCM handling, CallKit integration, persistence |
| `lib/services/call_state_manager.dart` | Navigation state management |
| `lib/main.dart` | Event listening, navigation orchestration |
| `lib/screens/incoming_call_screen.dart` | Custom incoming call UI (foreground) |
| `lib/screens/call_screen.dart` | Audio playback screen |

## Event Flow

```
CallKit Native Events          Flutter Events              UI Actions
─────────────────────────────────────────────────────────────────────
actionCallIncoming      →                           →  (native UI shown)
actionCallAccept        →  CallEventAccepted        →  Navigate to CallScreen
actionCallDecline       →  CallEventDeclined        →  Dismiss UI
actionCallEnded         →  CallEventEnded           →  Reset state
actionCallTimeout       →  CallEventMissed          →  Dismiss UI
```

## Important Considerations

### 1. Don't Clear Data Too Early

The persisted call data must survive until `CallScreen` is definitely displayed. Android can restart the activity at any moment during navigation.

### 2. Background Isolate Limitations

The background FCM handler runs in a separate Dart isolate. It cannot:
- Access the main isolate's in-memory state
- Directly trigger UI navigation

That's why we persist to SharedPreferences - it's the bridge between isolates.

**Important:** The background isolate can be **reused** between calls! If you set in-memory state (like `_currentCall`) in the background handler, it will persist and cause stale state issues on subsequent calls. Use native CallKit's `activeCalls()` to check for duplicates instead of in-memory flags.

### 3. CallKit endAllCalls() Triggers Events

When we call `FlutterCallkitIncoming.endAllCalls()` to dismiss the native UI, it fires `actionCallEnded`. We handle this by checking if there's a pending accepted call before emitting `CallEventEnded`.

### 4. Stale Data Handling

Persisted call data older than 2 minutes is considered stale and ignored. This prevents showing old calls on app launch.

```dart
if (DateTime.now().difference(persistedAt).inMinutes > 2) {
  return null;  // Stale, ignore
}
```

## Debugging Tips

Enable these logs to trace call flow:

```
CallService: Handling background message
CallService: Persisted incoming call data
CallService: CallKit event: Event.actionCallAccept
CallStateManager: Found persisted pending call
main: Found pending accepted call
main: Navigating to CallScreen
```

If calls aren't working:

1. Check if `loadPersistedIncomingCall` finds data (`raw=...` log)
2. Verify `_checkForPendingAcceptedCall` runs after activity restart
3. Ensure `CallScreen.initState` runs (means navigation succeeded)
