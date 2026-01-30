import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:record/record.dart';

import '../models/stt_models.dart';

/// Service for capturing audio from the microphone as PCM data.
/// Streams audio chunks suitable for real-time STT processing.
class AudioRecorderService {
  final AudioRecorder _recorder = AudioRecorder();
  StreamSubscription<Uint8List>? _recordingSubscription;
  bool _isRecording = false;

  final _audioChunkController = StreamController<Uint8List>.broadcast();
  final _errorController = StreamController<SttError>.broadcast();

  /// Stream of audio chunks (PCM data)
  Stream<Uint8List> get audioChunks => _audioChunkController.stream;

  /// Stream of recording errors
  Stream<SttError> get errors => _errorController.stream;

  /// Whether currently recording
  bool get isRecording => _isRecording;

  /// Start recording audio from the microphone.
  /// Audio is captured as 16kHz mono 16-bit PCM and streamed in chunks.
  Future<bool> startRecording({int sampleRate = 16000}) async {
    if (_isRecording) {
      debugPrint('AudioRecorderService: Already recording');
      return true;
    }

    try {
      // Check if we have permission
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        _errorController.add(const SttError(
          type: SttErrorType.microphoneError,
          message: 'Microphone permission not granted',
        ));
        return false;
      }

      // Configure recording for PCM streaming
      final config = RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: sampleRate,
        numChannels: 1, // Mono
        bitRate: sampleRate * 16, // 16-bit samples
      );

      // Start the recording stream
      final stream = await _recorder.startStream(config);
      _isRecording = true;

      _recordingSubscription = stream.listen(
        (data) {
          if (!_audioChunkController.isClosed) {
            _audioChunkController.add(data);
          }
        },
        onError: (error) {
          debugPrint('AudioRecorderService: Recording error: $error');
          _errorController.add(SttError(
            type: SttErrorType.microphoneError,
            message: 'Recording error: $error',
            originalError: error,
          ));
        },
        onDone: () {
          debugPrint('AudioRecorderService: Recording stream completed');
          _isRecording = false;
        },
      );

      debugPrint('AudioRecorderService: Started recording at ${sampleRate}Hz');
      return true;
    } catch (e) {
      debugPrint('AudioRecorderService: Failed to start recording: $e');
      _errorController.add(SttError(
        type: SttErrorType.microphoneError,
        message: 'Failed to start recording: $e',
        originalError: e,
      ));
      return false;
    }
  }

  /// Stop recording audio.
  Future<void> stopRecording() async {
    if (!_isRecording) {
      return;
    }

    try {
      await _recordingSubscription?.cancel();
      _recordingSubscription = null;

      await _recorder.stop();
      _isRecording = false;
      debugPrint('AudioRecorderService: Stopped recording');
    } catch (e) {
      debugPrint('AudioRecorderService: Error stopping recording: $e');
      _isRecording = false;
    }
  }

  /// Check if microphone permission is granted.
  Future<bool> hasPermission() async {
    return await _recorder.hasPermission();
  }

  /// Clean up resources.
  Future<void> dispose() async {
    await stopRecording();
    await _audioChunkController.close();
    await _errorController.close();
    _recorder.dispose();
  }
}
