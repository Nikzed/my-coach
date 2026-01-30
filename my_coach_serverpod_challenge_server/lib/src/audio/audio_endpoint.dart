import 'dart:convert';
import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../services/gcs_storage_service.dart';

/// Endpoint for streaming audio files for coach messages.
class AudioEndpoint extends Endpoint {
  /// Requires authentication for all methods in this endpoint.
  @override
  bool get requireLogin => true;

  /// Verifies that the authenticated user owns the task associated with a
  /// message.
  /// Returns the task if ownership is verified, throws if not authorized.
  Future<Task> _verifyMessageOwnership(
    Session session,
    CoachMessage message,
  ) async {
    final auth = session.authenticated;
    if (auth == null) {
      throw Exception('User must be authenticated');
    }

    final task = await Task.db.findById(session, message.taskId);
    if (task == null) {
      throw ArgumentError('Associated task not found');
    }

    if (task.userId != auth.userIdentifier) {
      throw Exception('Not authorized to access this message');
    }

    return task;
  }

  /// Gets the audio data for a coach message.
  /// Returns the audio as a base64-encoded string (Serverpod can't serialize
  /// Uint8List).
  /// Only the owner of the associated task can access the audio.
  Future<String?> getAudio(Session session, int messageId) async {
    final message = await CoachMessage.db.findById(session, messageId);
    if (message == null) {
      throw ArgumentError('Message not found');
    }

    // Verify ownership
    await _verifyMessageOwnership(session, message);

    if (message.audioStoragePath == null) {
      return null;
    }

    final path = message.audioStoragePath!;

    if (path.startsWith('gcs://')) {
      // Google Cloud Storage
      final objectPath = path.substring(6);
      try {
        final gcsService = GcsStorageService(
          bucketName: 'my-coach-flutter-audio',
        );
        final bytes =
            await gcsService.downloadAudio(objectPath);
        return base64Encode(bytes);
      } catch (e) {
        session.log(
          'Audio file not found in GCS: $objectPath',
        );
        return null;
      }
    }

    // Local filesystem (development)
    final audioFile = File(path);
    if (!await audioFile.exists()) {
      session.log(
        'Audio file not found: ${message.audioStoragePath}',
      );
      return null;
    }

    final bytes = await audioFile.readAsBytes();
    return base64Encode(bytes);
  }

  /// Gets the coach message details including text content.
  /// Only the owner of the associated task can access the message.
  Future<CoachMessage?> getMessage(Session session, int messageId) async {
    final message = await CoachMessage.db.findById(session, messageId);
    if (message == null) {
      return null;
    }

    // Verify ownership
    await _verifyMessageOwnership(session, message);

    return message;
  }

  /// Gets all messages for a specific task.
  /// Only the owner of the task can access its messages.
  Future<List<CoachMessage>> getMessagesForTask(
    Session session,
    int taskId,
  ) async {
    final auth = session.authenticated;
    if (auth == null) {
      throw Exception('User must be authenticated');
    }

    // Verify task ownership
    final task = await Task.db.findById(session, taskId);
    if (task == null) {
      throw ArgumentError('Task not found');
    }

    if (task.userId != auth.userIdentifier) {
      throw Exception('Not authorized to access messages for this task');
    }

    return await CoachMessage.db.find(
      session,
      where: (m) => m.taskId.equals(taskId),
      orderBy: (m) => m.generatedAt,
      orderDescending: true,
    );
  }
}
