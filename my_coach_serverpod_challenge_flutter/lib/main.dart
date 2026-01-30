import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:my_coach_serverpod_challenge_client/my_coach_serverpod_challenge_client.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';

import 'bloc/bloc_exports.dart';
import 'config/app_config.dart';
import 'screens/call_screen.dart';
import 'screens/home_screen.dart';
import 'screens/incoming_call_screen.dart';
import 'services/call_service.dart';
import 'services/call_state_manager.dart';
import 'services/settings_service.dart';
import 'theme/app_theme.dart';

/// Global client instance for Serverpod communication
late final Client client;

/// Global app configuration
late final AppConfig appConfig;

/// Global auth session manager
final FlutterAuthSessionManager sessionManager = FlutterAuthSessionManager();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style for dark theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Serverpod client
  // Config automatically detects emulator vs physical device:
  // - Emulator: uses 10.0.2.2 (Android special alias for host)
  // - Physical device: uses local network IP from config.json
  appConfig = await AppConfig.loadConfig();
  final serverUrl = appConfig.apiUrl ?? "https://my-coach-server-726428908817.europe-central2.run.app/";

  client = Client(serverUrl)
    ..connectivityMonitor = FlutterConnectivityMonitor()
    ..authSessionManager = sessionManager;

  // Initialize Google Sign-In with the server's Web Application Client ID
  client.auth.initializeGoogleSignIn(
    serverClientId: '726428908817-08rq3a4h4e3h8qmas9anltfc91ou0ph5.apps.googleusercontent.com',
  );

  // Initialize session manager with error handling
  try {
    await sessionManager.initialize();
    // Check if user is already signed in from persisted session
    final isSignedIn = await client.modules.serverpod_auth_core.status.isSignedIn();
    if (isSignedIn) {
      authStateNotifier.value = true;
      debugPrint("User session restored - already signed in");
    }
  } catch (e) {
    debugPrint("Failed to initialize session manager: $e, maybe you forgot to run the server :)");
    // Continue app startup even if session initialization fails
  }

  // Initialize call service (handles Firebase and CallKit)
  try {
    await CallService.instance.initialize();
  } catch (e) {
    debugPrint("Failed to initialize call service: $e");
  }

  // Initialize settings service
  await SettingsService.instance.initialize();

  runApp(
    MyCoachApp(client: client),
  );
}

class MyCoachApp extends StatefulWidget {
  final Client client;

  const MyCoachApp({super.key, required this.client});

  @override
  State<MyCoachApp> createState() => _MyCoachAppState();
}

class _MyCoachAppState extends State<MyCoachApp> with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription<CallEvent>? _callSubscription;

  // Centralized call navigation state manager
  final _callStateManager = CallStateManager();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _listenForCallEvents();
    // Check for pending accepted call after frame renders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForPendingAcceptedCall();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _callSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-check for pending accepted calls when app returns
      // from background (e.g. user accepted via native CallKit UI)
      _checkForPendingAcceptedCall();
    }
  }

  Future<void> _checkForPendingAcceptedCall() async {
    debugPrint('main: Checking for pending accepted call...');
    // Use centralized state manager to check for pending calls
    final pendingCall = await _callStateManager.checkForPendingCall();
    if (pendingCall != null) {
      debugPrint('main: Found pending accepted call: ${pendingCall.messageId}');
      _navigateToCallScreen(pendingCall);
    } else {
      debugPrint('main: No pending call found');
    }
  }

  void _listenForCallEvents() {
    // Check for a call that was accepted during main() initialization,
    // before this listener existed. Broadcast streams don't buffer, so
    // events emitted before subscription are lost.
    final pending = CallService.instance.consumePendingAcceptedCall();
    if (pending != null) {
      debugPrint('main: Found pending accepted call, navigating');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToCallScreen(pending);
      });
    }

    _callSubscription = CallService.instance.events.listen((event) {
      switch (event) {
        case CallEventAccepted(data: final callData):
          // Consume pending marker to prevent double navigation.
          CallService.instance.consumePendingAcceptedCall();
          _navigateToCallScreen(callData);
          break;
        case CallEventIncoming(data: final callData):
          _navigateToIncomingCallScreen(callData);
          break;
        case CallEventDeclined():
        case CallEventMissed():
          // Reset state so new calls can come through.
          _callStateManager.endCall();
          break;
        case CallEventEnded():
          // Call ended — reset state so new calls can come through.
          _callStateManager.endCall();
          break;
      }
    });
  }

  void _navigateToIncomingCallScreen(CallData callData) {
    // Use centralized state manager to check if we can show incoming call
    if (!_callStateManager.canShowIncomingCall) {
      debugPrint('main: Cannot show incoming call - state: ${_callStateManager.state}');
      return;
    }

    // Skip if there's a pending accepted call (in-memory state available)
    if (CallService.instance.pendingAcceptedCall != null) {
      debugPrint('main: Skipping incoming call screen — pending accepted call exists');
      return;
    }

    // Only show if we have a valid navigator
    final navigator = _navigatorKey.currentState;
    if (navigator == null) return;

    _callStateManager.showIncoming(callData);

    navigator.push(
      MaterialPageRoute(
        builder: (context) => IncomingCallScreen(
          callData: callData,
        ),
      ),
    );
  }

  void _navigateToCallScreen(CallData callData) {
    final navigator = _navigatorKey.currentState;
    if (navigator == null) {
      // Navigator not ready - schedule retry after next frame
      debugPrint('main: Navigator not ready, scheduling retry');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToCallScreen(callData);
      });
      return;
    }

    // Use centralized state manager to prevent duplicate navigation
    if (!_callStateManager.canNavigateToCall) {
      debugPrint('main: Cannot navigate to call - state: ${_callStateManager.state}');
      return;
    }
    _callStateManager.beginNavigation(callData);

    // Mark the call as active in CallService for FCM blocking
    CallService.instance.setActiveCall(callData);

    // End native CallKit UI, but DON'T clear persisted data yet.
    // If Android restarts the activity before navigation completes,
    // the new engine needs the persisted data to navigate to CallScreen.
    // Persisted data will be cleared by CallScreen after it's displayed.
    FlutterCallkitIncoming.endAllCalls();

    debugPrint('main: Navigating to CallScreen');

    navigator.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => CallScreen(callData: callData),
      ),
      (route) => route.isFirst,
    );

    // NOTE: CallStateManager state remains in navigatingToCall/inCall
    // until CallEventEnded is received, preventing late-arriving FCM
    // messages from showing IncomingCallScreen.
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            signOutCallback: () => sessionManager.signOutDevice(),
          )..add(const AuthCheckRequested()),
        ),
        BlocProvider<TasksBloc>(
          create: (context) => TasksBloc(client: widget.client),
        ),
        BlocProvider<CoachesBloc>(
          create: (context) => CoachesBloc(client: widget.client)..add(const CoachesLoadRequested()),
        ),
      ],
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        title: "My Coach",
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

/// Wrapper that shows sign-in screen when not authenticated
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        // Load tasks and register device when user becomes authenticated
        if (state.isAuthenticated) {
          context.read<TasksBloc>().add(const TasksLoadRequested());
          // Register device for push notifications
          CallService.instance.registerDevice();
        }
      },
      builder: (context, state) {
        if (state.isAuthenticated) {
          return HomeScreen(
            onSignOut: () {
              // Unregister device before signing out
              CallService.instance.unregisterDevice();
              context.read<AuthBloc>().add(const AuthSignOutRequested());
            },
          );
        }

        return const SignInPage();
      },
    );
  }
}

/// Beautiful sign-in page
class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  void _showAuthError(BuildContext context, Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Auth error: $error',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 10),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.background,
              AppTheme.accent.withValues(alpha: 0.1),
              AppTheme.background,
            ],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final topPadding = MediaQuery.of(context).padding.top + 32;
            final bottomPadding = MediaQuery.of(context).padding.bottom + 32;
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: topPadding,
                bottom: bottomPadding,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - topPadding - bottomPadding,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top content
                    Column(
                      children: [
                        const SizedBox(height: 24),
                        Text(
                          "My Coach",
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            color: AppTheme.accent,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Have someone to go through your "
                          "goals with!",
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        // Features
                        _FeatureItem(
                          icon: "📋",
                          title: "Create Tasks",
                          description: "Set your goals with deadlines",
                        ),
                        const SizedBox(height: 16),
                        _FeatureItem(
                          icon: "🎖️",
                          title: "Choose Your Coach",
                          description:
                              "Sergeant for tough guidance or "
                              "Melly for soothing support",
                        ),
                        const SizedBox(height: 16),
                        _FeatureItem(
                          icon: "📞",
                          title: "Get Called",
                          description:
                              "Your coach will call to remind "
                              "you or check in if you miss a "
                              "deadline",
                        ),
                        const SizedBox(height: 32),
                        // Sign in widget
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 24,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF2A2A30),
                            ),
                          ),
                          child: GoogleSignInWidget(
                            client: client,
                            onAuthenticated: () {
                              authStateNotifier.value = true;
                            },
                            onError: (error) {
                              _showAuthError(context, error);
                            },
                          ),
                        ),
                      ],
                    ),
                    // Footer pinned to bottom
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Text(
                        "@2026 My Coach\n"
                        "Made for the Serverpod Challenge",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(icon, style: const TextStyle(fontSize: 24)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
