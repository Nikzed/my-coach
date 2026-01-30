import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing user settings stored locally.
class SettingsService {
  static const String _defaultCoachIdKey = 'default_coach_id';

  static SettingsService? _instance;
  static SettingsService get instance => _instance ??= SettingsService._();

  SettingsService._();

  SharedPreferences? _prefs;

  /// Initialize the settings service. Must be called before using.
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Get the default coach ID, or null if not set.
  int? get defaultCoachId => _prefs?.getInt(_defaultCoachIdKey);

  /// Set the default coach ID. Pass null to clear.
  Future<void> setDefaultCoachId(int? coachId) async {
    if (coachId == null) {
      await _prefs?.remove(_defaultCoachIdKey);
    } else {
      await _prefs?.setInt(_defaultCoachIdKey, coachId);
    }
  }
}
