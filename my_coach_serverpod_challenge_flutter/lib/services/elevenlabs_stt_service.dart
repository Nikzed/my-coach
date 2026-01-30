import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/stt_models.dart';

/// Service for ElevenLabs Scribe v2 Realtime speech-to-text.
/// Handles WebSocket connection, audio streaming, and transcript parsing.
class ElevenLabsSttService {
  static const String _baseUrl = 'wss://api.elevenlabs.io/v1/speech-to-text/realtime';
  static const int _maxReconnectAttempts = 5;
  static const Duration _initialReconnectDelay = Duration(seconds: 1);

  final String apiKey;
  final SttConfig config;

  WebSocketChannel? _channel;
  StreamSubscription? _channelSubscription;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  bool _intentionalDisconnect = false;

  final _connectionStateController = StreamController<SttConnectionState>.broadcast();
  final _transcriptController = StreamController<SttTranscript>.broadcast();
  final _errorController = StreamController<SttError>.broadcast();

  SttConnectionState _currentState = SttConnectionState.disconnected;

  /// Stream of connection state changes
  Stream<SttConnectionState> get connectionState => _connectionStateController.stream;

  /// Stream of transcripts (both partial and committed)
  Stream<SttTranscript> get transcripts => _transcriptController.stream;

  /// Stream of errors
  Stream<SttError> get errors => _errorController.stream;

  /// Current connection state
  SttConnectionState get currentConnectionState => _currentState;

  /// Whether currently connected
  bool get isConnected => _currentState == SttConnectionState.connected;

  ElevenLabsSttService({
    required this.apiKey,
    this.config = const SttConfig(),
  });

  /// Connect to ElevenLabs STT WebSocket
  Future<bool> connect() async {
    if (_currentState == SttConnectionState.connected ||
        _currentState == SttConnectionState.connecting) {
      debugPrint('ElevenLabsSttService: Already connected or connecting');
      return _currentState == SttConnectionState.connected;
    }

    _intentionalDisconnect = false;
    _updateConnectionState(SttConnectionState.connecting);

    try {
      // Build URL without auth (auth via header)
      final uri = Uri.parse(config.toWebSocketUrlWithoutAuth(_baseUrl));
      debugPrint('ElevenLabsSttService: Connecting to $uri with xi-api-key header');

      // Use IOWebSocketChannel with headers for authentication
      _channel = IOWebSocketChannel.connect(
        uri,
        headers: {
          'xi-api-key': apiKey,
        },
      );

      // Wait for connection to be established
      await _channel!.ready;

      _channelSubscription = _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDone,
      );

      _updateConnectionState(SttConnectionState.connected);
      _reconnectAttempts = 0;
      debugPrint('ElevenLabsSttService: Connected to ElevenLabs STT (model: ${config.model})');
      return true;
    } catch (e) {
      debugPrint('ElevenLabsSttService: Connection failed: $e');
      _updateConnectionState(SttConnectionState.error);
      _errorController.add(SttError(
        type: SttErrorType.connectionFailed,
        message: 'Failed to connect to ElevenLabs STT: $e',
        originalError: e,
      ));
      _scheduleReconnect();
      return false;
    }
  }

  /// Disconnect from the WebSocket
  Future<void> disconnect() async {
    _intentionalDisconnect = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    await _channelSubscription?.cancel();
    _channelSubscription = null;

    await _channel?.sink.close();
    _channel = null;

    _updateConnectionState(SttConnectionState.disconnected);
    debugPrint('ElevenLabsSttService: Disconnected');
  }

  /// Send audio data to the WebSocket
  void sendAudio(Uint8List audioData) {
    if (!isConnected || _channel == null) {
      return;
    }

    try {
      // Send audio as JSON message with base64 encoding (new API format)
      final message = jsonEncode({
        'message_type': 'input_audio_chunk',
        'audio_base_64': base64Encode(audioData),
        'sample_rate': config.sampleRate,
      });
      _channel!.sink.add(message);
    } catch (e) {
      debugPrint('ElevenLabsSttService: Error sending audio: $e');
    }
  }

  /// Request manual commit of current transcript
  void manualCommit() {
    if (!isConnected || _channel == null) {
      return;
    }

    try {
      // Send empty audio chunk with commit=true to finalize transcript
      final message = jsonEncode({
        'message_type': 'input_audio_chunk',
        'audio_base_64': '',
        'commit': true,
        'sample_rate': config.sampleRate,
      });
      _channel!.sink.add(message);
      debugPrint('ElevenLabsSttService: Sent manual commit');
    } catch (e) {
      debugPrint('ElevenLabsSttService: Error sending commit: $e');
    }
  }

  void _handleMessage(dynamic message) {
    if (message is! String) {
      return;
    }

    try {
      final data = jsonDecode(message) as Map<String, dynamic>;
      // Check both new format (message_type) and legacy format (type)
      final messageType = data['message_type'] as String?;
      final legacyType = data['type'] as String?;
      final type = messageType ?? legacyType;

      switch (type) {
        // Session started acknowledgment
        case 'session_started':
        case 'SessionStarted':
          debugPrint('ElevenLabsSttService: Session started - '
              'session_id: ${data['session_id']}');
          break;

        // Partial transcript
        case 'partial_transcript':
        case 'PartialTranscript':
        case 'partial':
          final text = data['text'] as String? ?? '';
          if (text.isNotEmpty) {
            _transcriptController.add(SttTranscript(
              type: SttTranscriptType.partial,
              text: text,
              confidence: (data['confidence'] as num?)?.toDouble(),
              timestamp: DateTime.now(),
              words: _parseWords(data['words']),
            ));
          }
          break;

        // Committed transcript
        case 'committed_transcript':
        case 'CommittedTranscript':
        case 'committed':
          final text = data['text'] as String? ?? '';
          if (text.isNotEmpty) {
            _transcriptController.add(SttTranscript(
              type: SttTranscriptType.committed,
              text: text,
              confidence: (data['confidence'] as num?)?.toDouble(),
              timestamp: DateTime.now(),
              words: _parseWords(data['words']),
              detectedLanguage: data['language'] as String?,
            ));
          }
          break;

        // Error messages
        case 'input_error':
        case 'Error':
        case 'error':
        case 'auth_error':
          final errorMessage = data['message'] as String? ??
              data['error'] as String? ?? 'Unknown error';
          final errorCode = data['code'] as String? ?? type;
          debugPrint('ElevenLabsSttService: Server error: $errorCode - $errorMessage');
          debugPrint('ElevenLabsSttService: Full error data: $data');
          // Don't emit input_error as it's often just "no audio to commit"
          if (type != 'input_error') {
            _errorController.add(SttError(
              type: _mapErrorCode(errorCode),
              message: errorMessage,
            ));
          }
          break;

        // Legacy: config acknowledgment
        case 'config_ack':
          debugPrint('ElevenLabsSttService: Config acknowledged (legacy)');
          break;

        default:
          debugPrint('ElevenLabsSttService: Unknown message type: $type');
      }
    } catch (e) {
      debugPrint('ElevenLabsSttService: Error parsing message: $e');
    }
  }

  /// Parse word timestamps if present
  List<SttWord>? _parseWords(dynamic wordsData) {
    if (wordsData is! List) return null;
    try {
      return wordsData.map<SttWord>((w) => SttWord(
        word: w['word'] as String? ?? '',
        start: (w['start'] as num?)?.toDouble() ?? 0,
        end: (w['end'] as num?)?.toDouble() ?? 0,
      )).toList();
    } catch (e) {
      debugPrint('ElevenLabsSttService: Error parsing words: $e');
      return null;
    }
  }

  /// Map API error codes to SttErrorType
  SttErrorType _mapErrorCode(String? code) {
    switch (code) {
      case 'auth_error':
      case 'invalid_api_key':
      case 'invalid_token':
      case 'unauthorized':
        return SttErrorType.authenticationFailed;
      case 'connection_error':
        return SttErrorType.connectionLost;
      case 'rate_limited':
      case 'quota_exceeded':
        return SttErrorType.connectionFailed;
      default:
        return SttErrorType.unknown;
    }
  }

  void _handleError(dynamic error) {
    debugPrint('ElevenLabsSttService: WebSocket error: $error');
    _updateConnectionState(SttConnectionState.error);

    if (error.toString().contains('401') || error.toString().contains('403')) {
      _errorController.add(SttError(
        type: SttErrorType.authenticationFailed,
        message: 'Authentication failed. Check your API key.',
        originalError: error,
      ));
    } else {
      _errorController.add(SttError(
        type: SttErrorType.connectionLost,
        message: 'Connection error: $error',
        originalError: error,
      ));
      _scheduleReconnect();
    }
  }

  void _handleDone() {
    debugPrint('ElevenLabsSttService: WebSocket closed');

    if (!_intentionalDisconnect) {
      _updateConnectionState(SttConnectionState.disconnected);
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_intentionalDisconnect || _reconnectAttempts >= _maxReconnectAttempts) {
      if (_reconnectAttempts >= _maxReconnectAttempts) {
        debugPrint('ElevenLabsSttService: Max reconnect attempts reached');
        _errorController.add(const SttError(
          type: SttErrorType.connectionFailed,
          message: 'Could not reconnect after multiple attempts',
        ));
      }
      return;
    }

    _updateConnectionState(SttConnectionState.reconnecting);

    // Exponential backoff with jitter
    final delay = _initialReconnectDelay * pow(2, _reconnectAttempts);
    final jitter = Duration(milliseconds: Random().nextInt(1000));
    final totalDelay = delay + jitter;

    debugPrint('ElevenLabsSttService: Scheduling reconnect in ${totalDelay.inMilliseconds}ms '
        '(attempt ${_reconnectAttempts + 1}/$_maxReconnectAttempts)');

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(totalDelay, () {
      _reconnectAttempts++;
      connect();
    });
  }

  void _updateConnectionState(SttConnectionState state) {
    if (_currentState != state) {
      _currentState = state;
      _connectionStateController.add(state);
    }
  }

  /// Clean up resources
  Future<void> dispose() async {
    await disconnect();
    await _connectionStateController.close();
    await _transcriptController.close();
    await _errorController.close();
  }
}
