import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../bloc/auth/auth_bloc.dart';
import '../main.dart';
import '../theme/app_theme.dart';

/// Authentication wrapper that shows sign-in when not authenticated
class SignInScreen extends StatefulWidget {
  final Widget child;
  const SignInScreen({super.key, required this.child});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  @override
  void initState() {
    super.initState();
    authStateNotifier.addListener(_updateSignedInState);
  }

  @override
  void dispose() {
    authStateNotifier.removeListener(_updateSignedInState);
    super.dispose();
  }

  void _updateSignedInState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return authStateNotifier.value
        ? widget.child
        : Scaffold(
            backgroundColor: AppTheme.background,
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.accent,
                              AppTheme.accentDark,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                          child: Text(
                            '🎯',
                            style: TextStyle(fontSize: 40),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Welcome to MyCoach',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppTheme.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to get started',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 32),
                      // Sign-in form container
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF2A2A30),
                          ),
                        ),
                        child: SignInWidget(
                          client: client,
                          googleSignInWidget: GoogleSignInWidget(
                            client: client,
                            onAuthenticated: () {
                              authStateNotifier.value = true;
                            },
                          ),
                          onAuthenticated: () {
                            authStateNotifier.value = true;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
