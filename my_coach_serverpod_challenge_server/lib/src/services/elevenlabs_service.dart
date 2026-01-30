import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';

import 'gcs_storage_service.dart';

/// Service for converting text to speech using ElevenLabs API.
class ElevenLabsService {
  static const String _baseUrl = 'https://api.elevenlabs.io/v1';

  final String _apiKey;
  final http.Client _httpClient;
  final String _audioStorageDir;

  ElevenLabsService({
    required String apiKey,
    http.Client? httpClient,
    String? audioStorageDir,
  }) : _apiKey = apiKey,
       _httpClient = httpClient ?? http.Client(),
       _audioStorageDir = audioStorageDir ?? 'storage/audio';

  /// Factory constructor to create ElevenLabsService from Serverpod session.
  factory ElevenLabsService.fromSession(Session session) {
    final apiKey = session.passwords['elevenLabsApiKey'];
    if (apiKey == null || apiKey.isEmpty) {
      throw StateError('ElevenLabs API key not configured in passwords.yaml');
    }
    return ElevenLabsService(apiKey: apiKey);
  }

  /// Converts text to speech and stores the audio file.
  ///
  /// [text] - The text content to convert to speech
  /// [voiceId] - The ElevenLabs voice ID (from Coach.elevenLabsVoiceId)
  /// [messageId] - Unique identifier for the message (used in filename)
  /// [modelId] - Optional model ID (defaults to eleven_flash_v2_5)
  /// [stability] - Optional voice stability (0.0-1.0, defaults to 0.5)
  /// [similarity] - Optional similarity boost (0.0-1.0, defaults to 0.75)
  /// [style] - Optional style (0.0-1.0, defaults to 0.0)
  /// [speed] - Optional speed (0.5-2.0, defaults to 1.0)
  /// [speakerBoost] - Optional speaker boost (defaults to true)
  ///
  /// Returns the storage path of the generated audio file.
  ///
  /// When [gcsService] is provided, audio is uploaded to Google Cloud
  /// Storage and the returned path is prefixed with `gcs://`. When
  /// null, audio is saved to the local filesystem (development mode).
  Future<String> textToSpeech({
    required String text,
    required String voiceId,
    required int messageId,
    String? modelId,
    double? stability,
    double? similarity,
    double? style,
    double? speed,
    bool? speakerBoost,
    GcsStorageService? gcsService,
  }) async {
    final audioData = await _callTtsApi(
      text: text,
      voiceId: voiceId,
      modelId: modelId,
      stability: stability,
      similarity: similarity,
      style: style,
      speed: speed,
      speakerBoost: speakerBoost,
    );

    if (gcsService != null) {
      final objectPath = await gcsService.uploadAudio(
        audioData: audioData,
        messageId: messageId,
      );
      return 'gcs://$objectPath';
    }

    // Local filesystem storage (development)
    final storageDir = Directory(_audioStorageDir);
    if (!await storageDir.exists()) {
      await storageDir.create(recursive: true);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath =
        '$_audioStorageDir/message_${messageId}_$timestamp.mp3';
    final file = File(filePath);
    await file.writeAsBytes(audioData);

    return filePath;
  }

  /// Calls the ElevenLabs TTS API and returns raw audio bytes.
  Future<Uint8List> _callTtsApi({
    required String text,
    required String voiceId,
    String? modelId,
    double? stability,
    double? similarity,
    double? style,
    double? speed,
    bool? speakerBoost,
  }) async {
    final url = '$_baseUrl/text-to-speech/$voiceId';

    // Use defaults if not provided
    final effectiveModelId = modelId ?? 'eleven_flash_v2_5';
    final effectiveStability = stability ?? 0.5;
    final effectiveSimilarity = similarity ?? 0.75;
    final effectiveStyle = style ?? 0.0;
    final effectiveSpeakerBoost = speakerBoost ?? true;

    // Build voice_settings object
    final voiceSettings = StringBuffer();
    voiceSettings.write('"stability": $effectiveStability');
    voiceSettings.write(', "similarity_boost": $effectiveSimilarity');
    voiceSettings.write(', "style": $effectiveStyle');
    voiceSettings.write(', "use_speaker_boost": $effectiveSpeakerBoost');
    if (speed != null) {
      voiceSettings.write(', "speed": $speed');
    }

    final body = '''
{
  "text": ${_escapeJson(text)},
  "model_id": "$effectiveModelId",
  "voice_settings": {
    ${voiceSettings.toString()}
  }
}
''';

    final response = await _httpClient.post(
      Uri.parse(url),
      headers: {
        'xi-api-key': _apiKey,
        'Content-Type': 'application/json',
        'Accept': 'audio/mpeg',
      },
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'ElevenLabs API error: ${response.statusCode} - ${response.body}',
      );
    }

    return response.bodyBytes;
  }

  /// Escapes a string for JSON encoding.
  String _escapeJson(String text) {
    return '"${text.replaceAll('\\', '\\\\').replaceAll('"', '\\"').replaceAll('\n', '\\n').replaceAll('\r', '\\r').replaceAll('\t', '\\t')}"';
  }

  /// Gets the audio data directly without storing.
  Future<Uint8List> getAudioBytes({
    required String text,
    required String voiceId,
  }) async {
    return await _callTtsApi(text: text, voiceId: voiceId);
  }

  /// Closes the HTTP client.
  void dispose() {
    _httpClient.close();
  }
}
