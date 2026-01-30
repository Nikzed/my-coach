// =============================================================================
// DEPRECATED: Auth logic has been moved to AuthBloc
// =============================================================================
// See: lib/bloc/auth/auth_bloc.dart
// Keeping this file for reference during the migration period.
// =============================================================================

// import 'package:flutter/foundation.dart';
//
// import '../main.dart';
// import 'notification_service.dart';
//
// /// Service for handling authentication state and related side effects
// class AuthService {
//   AuthService._();
//   static final AuthService instance = AuthService._();
//
//   bool _isRegisteredForNotifications = false;
//
//   bool get isSignedIn => authStateNotifier.value;
//
//   /// Initialize auth listener
//   void initialize() {
//     authStateNotifier.addListener(_onAuthStateChanged);
//     
//     // Check initial auth state
//     if (isSignedIn) {
//       _onSignedIn();
//     }
//   }
//
//   void _onAuthStateChanged() {
//     if (isSignedIn) {
//       _onSignedIn();
//     } else {
//       _onSignedOut();
//     }
//   }
//
//   void _onSignedIn() async {
//     debugPrint('User signed in');
//     
//     // Register device for notifications
//     if (!_isRegisteredForNotifications) {
//       await NotificationService.instance.registerDevice();
//       _isRegisteredForNotifications = true;
//     }
//   }
//
//   void _onSignedOut() async {
//     debugPrint('User signed out');
//     
//     // Unregister device
//     if (_isRegisteredForNotifications) {
//       await NotificationService.instance.unregisterDevice();
//       _isRegisteredForNotifications = false;
//     }
//   }
//
//   /// Sign out the current user
//   Future<void> signOut() async {
//     await sessionManager.signOutDevice();
//     authStateNotifier.value = false;
//   }
//
//   void dispose() {
//     authStateNotifier.removeListener(_onAuthStateChanged);
//   }
// }
