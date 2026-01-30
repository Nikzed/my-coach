import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Endpoint for managing FCM device registrations.
class DeviceEndpoint extends Endpoint {
  /// Requires authentication for all methods in this endpoint.
  @override
  bool get requireLogin => true;

  /// Registers or updates an FCM token for the authenticated user's device.
  Future<UserDevice> registerDevice(
    Session session,
    String fcmToken,
    String platform,
  ) async {
    final auth = session.authenticated;
    if (auth == null) {
      throw Exception('User must be authenticated');
    }

    // Validate platform
    if (platform != 'android' && platform != 'ios') {
      throw ArgumentError('Platform must be "android" or "ios"');
    }

    // Check if device already exists for this user
    final existingDevice = await UserDevice.db.findFirstRow(
      session,
      where: (d) => d.userId.equals(auth.userIdentifier),
    );

    if (existingDevice != null) {
      // Update existing device
      existingDevice.fcmToken = fcmToken;
      existingDevice.platform = platform;
      existingDevice.lastUpdated = DateTime.now();
      return await UserDevice.db.updateRow(session, existingDevice);
    }

    // Remove any existing registration with this FCM token
    // (e.g., token recycled from another user or concurrent call)
    await UserDevice.db.deleteWhere(
      session,
      where: (d) => d.fcmToken.equals(fcmToken),
    );

    // Create new device registration
    final device = UserDevice(
      userId: auth.userIdentifier,
      fcmToken: fcmToken,
      platform: platform,
      lastUpdated: DateTime.now(),
    );

    return await UserDevice.db.insertRow(session, device);
  }

  /// Removes the device registration for the authenticated user.
  /// Returns the number of deleted devices.
  Future<int> unregisterDevice(Session session) async {
    final auth = session.authenticated;
    if (auth == null) {
      throw Exception('User must be authenticated');
    }

    final deleted = await UserDevice.db.deleteWhere(
      session,
      where: (d) => d.userId.equals(auth.userIdentifier),
    );
    return deleted.length;
  }
}
