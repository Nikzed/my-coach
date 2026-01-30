import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

import '../services/call_service.dart';
import '../theme/app_theme.dart';
import 'call_screen.dart';

/// Screen shown when an incoming coach call is received.
/// Displays coach information and accept/decline buttons.
class IncomingCallScreen extends StatefulWidget {
  final CallData callData;

  const IncomingCallScreen({
    super.key,
    required this.callData,
  });

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _shakeController;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // Shake animation controller with built-in repeat
    // Using 600ms total (100ms shake forward + 100ms reverse + 400ms pause)
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat();

    // Play the device's default ringtone while the screen is shown
    FlutterRingtonePlayer().playRingtone(
      looping: true,
      volume: 1.0,
    );
  }

  @override
  void dispose() {
    FlutterRingtonePlayer().stop();
    _pulseController.dispose();
    _shakeController.dispose();
    // If the screen is disposed without user explicitly accepting/declining
    // (e.g., system back gesture, app killed), clear the call state.
    // This prevents _currentCall from blocking future incoming calls.
    // Note: if user already accepted/declined, endCall() is a safe no-op.
    if (!_isNavigating) {
      CallService.instance.endCall();
    }
    super.dispose();
  }

  void _acceptCall() async {
    if (_isNavigating) return;
    _isNavigating = true;

    FlutterRingtonePlayer().stop();

    // Stop animations before navigating
    _pulseController.stop();
    _shakeController.stop();

    // Dismiss native CallKit UI if it was shown (background path).
    // Safe no-op when no native notification exists (foreground path).
    await FlutterCallkitIncoming.endCall(widget.callData.callId);

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => CallScreen(
          callData: widget.callData,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _declineCall() {
    if (_isNavigating) return;
    _isNavigating = true;

    FlutterRingtonePlayer().stop();
    CallService.instance.endCall();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final coachColor = widget.callData.coachName.coachPrimaryColor;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              coachColor.withValues(alpha: 0.15),
              AppTheme.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Coach avatar with pulse animation
              _buildCoachAvatar(coachColor),

              const SizedBox(height: 40),

              // Coach name
              Text(
                'Coach ${widget.callData.coachName}',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

              const SizedBox(height: 8),

              // Calling text
              Text(
                'is calling you...',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ).animate().fadeIn(delay: 300.ms),

              if (widget.callData.taskName != null) ...[
                const SizedBox(height: 16),
                _buildTaskBadge(context),
              ],

              const Spacer(flex: 3),

              // Action buttons
              _buildActionButtons(context),

              const Spacer(),

              // Hint text
              Text(
                'Tap to respond',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textMuted,
                    ),
              ).animate().fadeIn(delay: 700.ms),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoachAvatar(Color coachColor) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulse rings - each wrapped in RepaintBoundary for isolation
        ...List.generate(3, (index) {
          return RepaintBoundary(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final value = (_pulseController.value + index * 0.33) % 1.0;
                final size = 140 + (100 * value);
                return Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: coachColor.withValues(alpha: 0.4 * (1 - value)),
                      width: 2,
                    ),
                  ),
                );
              },
            ),
          );
        }),
        // Avatar
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                coachColor,
                coachColor.withValues(alpha: 0.7),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: coachColor.withValues(alpha: 0.4),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Center(
            child: Text(
              _getCoachEmoji(widget.callData.coachName),
              style: const TextStyle(fontSize: 64),
            ),
          ),
        ),
      ],
    ).animate().scale(
          begin: const Offset(0.8, 0.8),
          duration: 400.ms,
          curve: Curves.elasticOut,
        );
  }

  Widget _buildTaskBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 16,
            color: AppTheme.warning,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'About: ${widget.callData.taskName}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Decline button
          _CallActionButton(
            icon: Icons.call_end,
            color: AppTheme.error,
            label: 'Decline',
            onTap: _declineCall,
          ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.3),

          // Accept button with shake (only shakes in first third of cycle)
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _shakeController,
              builder: (context, child) {
                // Only shake in first 1/3 of animation (100ms out of 600ms)
                final shakeValue = _shakeController.value < 0.33
                    ? sin(_shakeController.value * 3 * pi * 4) * 3
                    : 0.0;
                return Transform.translate(
                  offset: Offset(shakeValue, 0),
                  child: child,
                );
              },
              child: _CallActionButton(
                icon: Icons.call,
                color: AppTheme.success,
                label: 'Accept',
                isPrimary: true,
                onTap: _acceptCall,
              ),
            ),
          ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.3),
        ],
      ),
    );
  }

  String _getCoachEmoji(String name) {
    switch (name.toLowerCase()) {
      case 'sergeant':
        return '🎖️';
      case 'melly':
        return '🌸';
      default:
        return '🏋️';
    }
  }
}

class _CallActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  const _CallActionButton({
    required this.icon,
    required this.color,
    required this.label,
    this.isPrimary = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: isPrimary ? 80 : 64,
            height: isPrimary ? 80 : 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: isPrimary
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: isPrimary ? 36 : 28,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
      ],
    );
  }
}
