import 'dart:developer';
import 'dart:typed_data';

import 'package:gcloud/storage.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;

/// Service for storing and retrieving audio files from Google Cloud
/// Storage. Uses Application Default Credentials which are
/// automatically available in Cloud Run environments.
class GcsStorageService {
  final String _bucketName;
  Storage? _storage;

  GcsStorageService({required String bucketName})
      : _bucketName = bucketName;

  Future<Storage> _getStorage() async {
    if (_storage != null) return _storage!;

    final client =
        await auth.clientViaApplicationDefaultCredentials(
      scopes: [
        'https://www.googleapis.com/auth/devstorage.read_write',
      ],
    );

    _storage = Storage(client, 'my-coach-flutter');
    return _storage!;
  }

  /// Uploads audio bytes to GCS and returns the object path.
  Future<String> uploadAudio({
    required Uint8List audioData,
    required int messageId,
  }) async {
    final storage = await _getStorage();
    final bucket = storage.bucket(_bucketName);
    final timestamp =
        DateTime.now().millisecondsSinceEpoch;
    final objectName =
        'audio/message_${messageId}_$timestamp.mp3';

    await bucket.writeBytes(
      objectName,
      audioData,
      metadata: ObjectMetadata(
        contentType: 'audio/mpeg',
      ),
    );

    log('GcsStorageService: Uploaded $objectName');
    return objectName;
  }

  /// Downloads audio bytes from GCS.
  Future<Uint8List> downloadAudio(String objectPath) async {
    final storage = await _getStorage();
    final bucket = storage.bucket(_bucketName);
    final bytes = <int>[];

    await for (final chunk in bucket.read(objectPath)) {
      bytes.addAll(chunk);
    }

    return Uint8List.fromList(bytes);
  }
}
