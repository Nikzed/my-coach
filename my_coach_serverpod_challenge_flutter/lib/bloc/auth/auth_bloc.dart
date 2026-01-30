import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/call_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Global auth state notifier for compatibility with SignInWidget
final authStateNotifier = ValueNotifier<bool>(false);

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Future<void> Function() signOutCallback;
  bool _isRegisteredForNotifications = false;

  AuthBloc({required this.signOutCallback}) : super(const AuthState.initial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignedIn>(_onAuthSignedIn);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
    on<AuthStateChanged>(_onAuthStateChanged);

    // Listen to external auth state changes (from SignInWidget)
    authStateNotifier.addListener(_onExternalAuthChange);
  }

  void _onExternalAuthChange() {
    add(AuthStateChanged(isAuthenticated: authStateNotifier.value));
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Check if already authenticated via the notifier
    if (authStateNotifier.value) {
      emit(const AuthState.authenticated());
      await _onSignedIn();
    } else {
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> _onAuthSignedIn(
    AuthSignedIn event,
    Emitter<AuthState> emit,
  ) async {
    authStateNotifier.value = true;
    emit(const AuthState.authenticated());
    await _onSignedIn();
  }

  Future<void> _onAuthSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await signOutCallback();
    authStateNotifier.value = false;
    emit(const AuthState.unauthenticated());
    await _onSignedOut();
  }

  Future<void> _onAuthStateChanged(
    AuthStateChanged event,
    Emitter<AuthState> emit,
  ) async {
    if (event.isAuthenticated) {
      emit(const AuthState.authenticated());
      await _onSignedIn();
    } else {
      emit(const AuthState.unauthenticated());
      await _onSignedOut();
    }
  }

  Future<void> _onSignedIn() async {
    debugPrint('User signed in');

    // Register device for notifications
    if (!_isRegisteredForNotifications) {
      try {
        await CallService.instance.registerDevice();
        _isRegisteredForNotifications = true;
      } catch (e) {
        debugPrint('Failed to register for notifications: $e');
      }
    }
  }

  Future<void> _onSignedOut() async {
    debugPrint('User signed out');

    // Unregister device
    if (_isRegisteredForNotifications) {
      try {
        await CallService.instance.unregisterDevice();
        _isRegisteredForNotifications = false;
      } catch (e) {
        debugPrint('Failed to unregister device: $e');
      }
    }
  }

  @override
  Future<void> close() {
    authStateNotifier.removeListener(_onExternalAuthChange);
    return super.close();
  }
}
