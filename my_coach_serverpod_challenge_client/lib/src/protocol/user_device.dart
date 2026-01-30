/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

/// User device registration for FCM push notifications
abstract class UserDevice implements _i1.SerializableModel {
  UserDevice._({
    this.id,
    required this.userId,
    required this.fcmToken,
    required this.platform,
    required this.lastUpdated,
  });

  factory UserDevice({
    int? id,
    required String userId,
    required String fcmToken,
    required String platform,
    required DateTime lastUpdated,
  }) = _UserDeviceImpl;

  factory UserDevice.fromJson(Map<String, dynamic> jsonSerialization) {
    return UserDevice(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as String,
      fcmToken: jsonSerialization['fcmToken'] as String,
      platform: jsonSerialization['platform'] as String,
      lastUpdated: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['lastUpdated'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// Reference to the user who owns this device (serverpod_auth user UUID)
  String userId;

  /// Firebase Cloud Messaging token for push notifications
  String fcmToken;

  /// Platform identifier ('android' or 'ios')
  String platform;

  /// When the FCM token was last updated
  DateTime lastUpdated;

  /// Returns a shallow copy of this [UserDevice]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  UserDevice copyWith({
    int? id,
    String? userId,
    String? fcmToken,
    String? platform,
    DateTime? lastUpdated,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UserDevice',
      if (id != null) 'id': id,
      'userId': userId,
      'fcmToken': fcmToken,
      'platform': platform,
      'lastUpdated': lastUpdated.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UserDeviceImpl extends UserDevice {
  _UserDeviceImpl({
    int? id,
    required String userId,
    required String fcmToken,
    required String platform,
    required DateTime lastUpdated,
  }) : super._(
         id: id,
         userId: userId,
         fcmToken: fcmToken,
         platform: platform,
         lastUpdated: lastUpdated,
       );

  /// Returns a shallow copy of this [UserDevice]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  UserDevice copyWith({
    Object? id = _Undefined,
    String? userId,
    String? fcmToken,
    String? platform,
    DateTime? lastUpdated,
  }) {
    return UserDevice(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      fcmToken: fcmToken ?? this.fcmToken,
      platform: platform ?? this.platform,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
