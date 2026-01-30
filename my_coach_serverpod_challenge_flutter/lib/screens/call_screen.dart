import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../main.dart';
import '../services/call_service.dart';
import '../theme/app_theme.dart';

/// Audio playback state for the call screen
enum CallAudioState {
  loading,
  playing,
  paused,
  completed,
  error,
}

/// Screen shown during an active coach call.
/// Plays audio message and displays the message text.
class CallScreen extends StatefulWidget {
  final CallData callData;

  const CallScreen({
    super.key,
    required this.callData,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();

  CallAudioState _audioState = CallAudioState.loading;
  String? _messageText;
  String? _errorMessage;

  late final AnimationController _waveController;
  Timer? _callTimer;
  int _callDurationSeconds = 0;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();

    // Clear persisted call data now that CallScreen is displayed.
    // This must happen HERE (not in main.dart) because Android may
    // restart the activity after navigation starts but before it completes.
    // If we clear too early, the new engine won't find the pending call.
    debugPrint('CallScreen: initState - clearing persisted call data');
    CallService.clearPersistedIncomingCall();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _setupAudioPlayer();
    _loadAndPlayAudio();
    _startCallTimer();
  }

  @override
  void dispose() {
    debugPrint('CallScreen: dispose() called');
    _isDisposed = true;
    _callTimer?.cancel();
    _waveController.dispose();
    _audioPlayer.dispose();
    // Ensure call state is cleared when screen is disposed
    // (e.g., user navigates away, app goes to background, etc.)
    // This prevents _currentCall from blocking future incoming calls.
    CallService.instance.endCall();
    super.dispose();
  }

  void _setupAudioPlayer() {
    // Listen to player state changes
    _audioPlayer.playerStateStream.listen((state) {
      if (_isDisposed) return;

      setState(() {
        // Check for completion first, as playing can still be true when completed
        if (state.processingState == ProcessingState.completed) {
          debugPrint("CallScreen: Audio completed, scheduling end call");
          _audioState = CallAudioState.completed;
          _waveController.stop();
          _scheduleCallEnd();
        } else if (state.playing) {
          _audioState = CallAudioState.playing;
          _waveController.repeat(reverse: true);
        } else if (_audioState == CallAudioState.playing) {
          _audioState = CallAudioState.paused;
          _waveController.stop();
        }
      });
    });

    // Listen to errors
    _audioPlayer.playbackEventStream.listen(
      (_) {},
      onError: (Object e, StackTrace stackTrace) {
        if (_isDisposed) return;
        debugPrint('CallScreen: Audio error: $e');
        setState(() {
          _audioState = CallAudioState.error;
          _errorMessage = 'Failed to play audio';
        });
      },
    );
  }

  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isDisposed) return;
      setState(() => _callDurationSeconds++);
    });
  }

  Future<void> _loadAndPlayAudio() async {
    try {
      // Load message text first
      final message = await client.audio.getMessage(widget.callData.messageId);
      if (_isDisposed) return;

      if (message != null) {
        setState(() => _messageText = message.textContent);
      }

      // Load audio data
      final audioBase64 = await client.audio.getAudio(widget.callData.messageId);
      if (_isDisposed) return;

      if (audioBase64 == null || audioBase64.isEmpty) {
        setState(() {
          _audioState = CallAudioState.error;
          _errorMessage = 'No audio available for this message';
        });
        return;
      }

      // Decode and play audio
      final audioData = base64Decode(audioBase64);
      final audioSource = _BytesAudioSource(audioData);
      await _audioPlayer.setAudioSource(audioSource);
      await _audioPlayer.play();
    } catch (e) {
      if (_isDisposed) return;
      debugPrint('CallScreen: Failed to load audio: $e');
      setState(() {
        _audioState = CallAudioState.error;
        _errorMessage = 'Failed to load audio. Please try again.';
      });
    }
  }

  void _scheduleCallEnd() {
    debugPrint("CallScreen: _scheduleCallEnd called");
    // Auto-dismiss 1 second after audio completes
    Future.delayed(const Duration(seconds: 1), () {
      if (_isDisposed || !mounted) return;
      _endCall();
    });
  }

  void _endCall() {
    debugPrint("CallScreen: _endCall called");
    CallService.instance.endCall();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final coachColor = widget.callData.coachName.coachPrimaryColor;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              coachColor.withValues(alpha: 0.2),
              AppTheme.background,
              AppTheme.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Call duration indicator
              _buildCallDurationBadge(context),

              const Spacer(),

              // Coach avatar with audio visualizer
              _buildCoachAvatar(coachColor),

              const SizedBox(height: 32),

              // Coach name and status
              _buildCoachInfo(context),

              const SizedBox(height: 32),

              // if (_messageText != null)
              //   Flexible(
              //     child: SingleChildScrollView(
              //       child: _buildMessageCard(context, coachColor),
              //     ),
              //   ),
              

              if (_errorMessage != null) _buildErrorMessage(context),

              const SizedBox(height: 24),

              // Control buttons
              _buildControlButtons(context),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCallDurationBadge(BuildContext context) {
    final isActive = _audioState == CallAudioState.playing;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? AppTheme.success : AppTheme.warning,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _formatDuration(Duration(seconds: _callDurationSeconds)),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoachAvatar(Color coachColor) {
    final isPlaying = _audioState == CallAudioState.playing;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Audio visualizer rings (only when playing)
        // Each ring wrapped in RepaintBoundary to isolate repaints
        if (isPlaying) ...[
          ...List.generate(3, (index) {
            return RepaintBoundary(
              child: AnimatedBuilder(
                animation: _waveController,
                builder: (context, child) {
                  final scale =
                      1.0 + (_waveController.value * 0.1 * (index + 1));
                  return Transform.scale(
                    scale: scale,
                    child: child,
                  );
                },
                // Pre-built static ring as child (doesn't rebuild)
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: coachColor.withValues(alpha: 0.3 - (index * 0.1)),
                      width: 3 - index.toDouble(),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],

        // Avatar
        Container(
          width: 160,
          height: 160,
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
                color: coachColor.withValues(alpha: 0.3),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Center(
            child: Text(
              _getCoachEmoji(widget.callData.coachName),
              style: const TextStyle(fontSize: 72),
            ),
          ),
        ), // .animate().scale(duration: 300.ms, curve: Curves.easeOut),
      ],
    );
  }

  Widget _buildCoachInfo(BuildContext context) {
    return Column(
      children: [
        Text(
          'Coach ${widget.callData.coachName}',
          style: Theme.of(context).textTheme.headlineLarge,
        ), // .animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 8),
        Text(
          _getStatusText(),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ), // .animate().fadeIn(delay: 200.ms),
      ],
    );
  }

  String _getStatusText() {
    switch (_audioState) {
      case CallAudioState.loading:
        return 'Connecting...';
      case CallAudioState.playing:
        return 'Speaking...';
      case CallAudioState.paused:
        return 'Paused';
      case CallAudioState.completed:
        return 'Message complete';
      case CallAudioState.error:
        return 'Error';
    }
  }

  Widget _buildMessageCard(BuildContext context, Color coachColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: coachColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.format_quote,
            color: coachColor.withValues(alpha: 0.5),
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            _messageText!,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: AppTheme.error,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.error,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              setState(() {
                _audioState = CallAudioState.loading;
                _errorMessage = null;
              });
              _loadAndPlayAudio();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons(BuildContext context) {
    return GestureDetector(
      onTap: _endCall,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.error,
          boxShadow: [
            BoxShadow(
              color: AppTheme.error.withValues(alpha: 0.4),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: const Icon(
          Icons.call_end,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
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

/// Custom audio source that reads from bytes in memory
class _BytesAudioSource extends StreamAudioSource {
  final Uint8List _bytes;

  _BytesAudioSource(this._bytes);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= _bytes.length;

    return StreamAudioResponse(
      sourceLength: _bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(_bytes.sublist(start, end)),
      contentType: 'audio/mpeg',
    );
  }
}
