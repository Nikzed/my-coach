import 'package:equatable/equatable.dart';

/// Connection state for STT WebSocket
enum SttConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

/// Type of transcript received from ElevenLabs
enum SttTranscriptType {
  partial,
  committed,
}

/// Represents a word with timestamp information
class SttWord extends Equatable {
  final String word;
  final double start;
  final double end;

  const SttWord({
    required this.word,
    required this.start,
    required this.end,
  });

  @override
  List<Object?> get props => [word, start, end];
}

/// Represents a transcript from ElevenLabs STT
class SttTranscript extends Equatable {
  final SttTranscriptType type;
  final String text;
  final double? confidence;
  final DateTime timestamp;
  final List<SttWord>? words;
  final String? detectedLanguage;

  const SttTranscript({
    required this.type,
    required this.text,
    this.confidence,
    required this.timestamp,
    this.words,
    this.detectedLanguage,
  });

  bool get isPartial => type == SttTranscriptType.partial;
  bool get isCommitted => type == SttTranscriptType.committed;

  @override
  List<Object?> get props => [type, text, confidence, timestamp, words, detectedLanguage];

  @override
  String toString() => 'SttTranscript($type, "$text")';
}

/// Configuration for STT session
class SttConfig {
  /// How long to wait after speech ends before committing (seconds)
  final double silenceThresholdSecs;

  /// VAD sensitivity threshold (0.0 to 1.0, higher = less sensitive)
  final double vadThreshold;

  /// Minimum silence duration to consider (milliseconds)
  final int minSilenceDurationMs;

  /// Minimum speech duration to start detection (milliseconds)
  final int minSpeechDurationMs;

  /// Audio sample rate in Hz
  final int sampleRate;

  /// Audio encoding format
  final String encoding;

  /// Model to use for transcription
  final String model;

  const SttConfig({
    this.silenceThresholdSecs = 2.5,
    this.vadThreshold = 0.4,
    this.minSilenceDurationMs = 100,
    this.minSpeechDurationMs = 100,
    this.sampleRate = 16000,
    this.encoding = 'pcm_s16le',
    this.model = 'scribe_v2_realtime',
  });

  /// Default configuration optimized for task input
  static const defaultConfig = SttConfig();

  /// Configuration for faster response (shorter silence threshold)
  static const quickConfig = SttConfig(
    silenceThresholdSecs: 1.5,
    vadThreshold: 0.3,
  );

  /// Generate WebSocket URL with all parameters as query string (including auth token)
  String toWebSocketUrl(String baseUrl, String apiKey) {
    final params = {
      'token': apiKey,
      'model_id': model,
      'audio_format': 'pcm_$sampleRate',
      'commit_strategy': 'vad',
      'vad_silence_threshold_secs': silenceThresholdSecs.toString(),
      'vad_threshold': vadThreshold.toString(),
      'min_silence_duration_ms': minSilenceDurationMs.toString(),
      'min_speech_duration_ms': minSpeechDurationMs.toString(),
    };
    return Uri.parse(baseUrl).replace(queryParameters: params).toString();
  }

  /// Generate WebSocket URL without auth (auth via header instead)
  String toWebSocketUrlWithoutAuth(String baseUrl) {
    final params = {
      'model_id': model,
      'audio_format': 'pcm_$sampleRate',
      'commit_strategy': 'vad',
      'vad_silence_threshold_secs': silenceThresholdSecs.toString(),
      'vad_threshold': vadThreshold.toString(),
      'min_silence_duration_ms': minSilenceDurationMs.toString(),
      'min_speech_duration_ms': minSpeechDurationMs.toString(),
    };
    return Uri.parse(baseUrl).replace(queryParameters: params).toString();
  }

  /// Generate WebSocket URL with API key as xi-api-key query param
  String toWebSocketUrlWithApiKey(String baseUrl, String apiKey) {
    final params = {
      'xi-api-key': apiKey,
      'model_id': model,
      'audio_format': 'pcm_$sampleRate',
      'commit_strategy': 'vad',
      'vad_silence_threshold_secs': silenceThresholdSecs.toString(),
      'vad_threshold': vadThreshold.toString(),
      'min_silence_duration_ms': minSilenceDurationMs.toString(),
      'min_speech_duration_ms': minSpeechDurationMs.toString(),
    };
    return Uri.parse(baseUrl).replace(queryParameters: params).toString();
  }
}

/// Error types for STT service
enum SttErrorType {
  connectionFailed,
  connectionLost,
  authenticationFailed,
  microphoneError,
  unknown,
}

/// Represents an STT error
class SttError extends Equatable {
  final SttErrorType type;
  final String message;
  final Object? originalError;

  const SttError({
    required this.type,
    required this.message,
    this.originalError,
  });

  @override
  List<Object?> get props => [type, message];

  @override
  String toString() => 'SttError($type: $message)';
}
