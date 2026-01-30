import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/stt_models.dart';
import 'audio_recorder_service.dart';
import 'elevenlabs_stt_service.dart';

/// Manages STT session by coordinating audio recorder and ElevenLabs service.
/// Provides a unified interface for the VoiceInputBloc.
class SttSessionManager {
  final String apiKey;
  final SttConfig config;

  late final AudioRecorderService _recorder;
  late final ElevenLabsSttService _sttService;

  StreamSubscription? _audioSubscription;
  StreamSubscription? _transcriptSubscription;
  StreamSubscription? _connectionSubscription;
  StreamSubscription? _recorderErrorSubscription;
  StreamSubscription? _sttErrorSubscription;

  bool _isSessionActive = false;
  String _currentPartialText = '';
  final List<String> _committedTexts = [];

  final _liveTranscriptController = StreamController<String>.broadcast();
  final _committedTranscriptController = StreamController<String>.broadcast();
  final _connectionStateController = StreamController<SttConnectionState>.broadcast();
  final _errorController = StreamController<SttError>.broadcast();

  /// Stream of live (partial) transcripts as the user speaks
  Stream<String> get liveTranscript => _liveTranscriptController.stream;

  /// Stream of committed transcripts (final text after VAD detects silence)
  Stream<String> get committedTranscript => _committedTranscriptController.stream;

  /// Stream of connection state changes
  Stream<SttConnectionState> get connectionState => _connectionStateController.stream;

  /// Stream of errors from recorder or STT service
  Stream<SttError> get errors => _errorController.stream;

  /// Whether a session is currently active
  bool get isSessionActive => _isSessionActive;

  /// Current connection state
  SttConnectionState get currentConnectionState => _sttService.currentConnectionState;

  /// Get all committed text so far
  String get fullCommittedText => _committedTexts.join(' ');

  SttSessionManager({
    required this.apiKey,
    this.config = const SttConfig(),
  }) {
    _recorder = AudioRecorderService();
    _sttService = ElevenLabsSttService(apiKey: apiKey, config: config);
    _setupListeners();
  }

  void _setupListeners() {
    // Forward connection state changes
    _connectionSubscription = _sttService.connectionState.listen((state) {
      _connectionStateController.add(state);
    });

    // Forward errors from STT service
    _sttErrorSubscription = _sttService.errors.listen((error) {
      _errorController.add(error);
    });

    // Forward errors from recorder
    _recorderErrorSubscription = _recorder.errors.listen((error) {
      _errorController.add(error);
    });
  }

  /// Start a new STT session.
  /// Connects to ElevenLabs and starts recording audio.
  Future<bool> startSession() async {
    if (_isSessionActive) {
      debugPrint('SttSessionManager: Session already active');
      return true;
    }

    _currentPartialText = '';
    _committedTexts.clear();

    // Connect to ElevenLabs first
    final connected = await _sttService.connect();
    if (!connected) {
      debugPrint('SttSessionManager: Failed to connect to ElevenLabs');
      return false;
    }

    // Start recording
    final recording = await _recorder.startRecording(sampleRate: config.sampleRate);
    if (!recording) {
      debugPrint('SttSessionManager: Failed to start recording');
      await _sttService.disconnect();
      return false;
    }

    // Subscribe to audio chunks and send to STT service
    _audioSubscription = _recorder.audioChunks.listen((audioData) {
      _sttService.sendAudio(audioData);
    });

    // Subscribe to transcripts
    _transcriptSubscription = _sttService.transcripts.listen((transcript) {
      if (transcript.isPartial) {
        _currentPartialText = transcript.text;
        // Emit live text: all committed + current partial
        final liveText = _buildLiveText();
        _liveTranscriptController.add(liveText);
      } else if (transcript.isCommitted) {
        _committedTexts.add(transcript.text);
        _currentPartialText = '';
        // Emit the full committed text
        _committedTranscriptController.add(fullCommittedText);
        // Also update live text to show committed state
        _liveTranscriptController.add(fullCommittedText);
      }
    });

    _isSessionActive = true;
    debugPrint('SttSessionManager: Session started');
    return true;
  }

  /// Stop the current session.
  /// Stops recording and disconnects from ElevenLabs.
  Future<void> stopSession() async {
    if (!_isSessionActive) {
      return;
    }

    _isSessionActive = false;

    await _audioSubscription?.cancel();
    _audioSubscription = null;

    await _transcriptSubscription?.cancel();
    _transcriptSubscription = null;

    await _recorder.stopRecording();
    await _sttService.disconnect();

    debugPrint('SttSessionManager: Session stopped');
  }

  /// Manually commit the current partial transcript.
  /// Use this for the "Done" button fallback.
  void manualCommit() {
    if (_isSessionActive) {
      _sttService.manualCommit();
    }
  }

  /// Get the current live text (committed + partial)
  String _buildLiveText() {
    if (_committedTexts.isEmpty) {
      return _currentPartialText;
    }
    if (_currentPartialText.isEmpty) {
      return fullCommittedText;
    }
    return '$fullCommittedText $_currentPartialText';
  }

  /// Check if microphone permission is granted
  Future<bool> hasPermission() async {
    return await _recorder.hasPermission();
  }

  /// Clean up all resources
  Future<void> dispose() async {
    await stopSession();

    await _connectionSubscription?.cancel();
    await _recorderErrorSubscription?.cancel();
    await _sttErrorSubscription?.cancel();

    await _liveTranscriptController.close();
    await _committedTranscriptController.close();
    await _connectionStateController.close();
    await _errorController.close();

    await _recorder.dispose();
    await _sttService.dispose();
  }
}
