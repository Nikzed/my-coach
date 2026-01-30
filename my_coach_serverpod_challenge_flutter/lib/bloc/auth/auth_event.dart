import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event to check current authentication status
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Event when user signs in successfully
class AuthSignedIn extends AuthEvent {
  const AuthSignedIn();
}

/// Event when user signs out
class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

/// Event when auth state changes externally
class AuthStateChanged extends AuthEvent {
  final bool isAuthenticated;

  const AuthStateChanged({required this.isAuthenticated});

  @override
  List<Object?> get props => [isAuthenticated];
}
