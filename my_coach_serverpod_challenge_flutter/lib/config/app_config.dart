import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AppConfig {
  final String? apiUrl;
  final String? elevenLabsApiKey;

  AppConfig({
    required this.apiUrl,
    this.elevenLabsApiKey,
  });

  static Future<AppConfig> loadConfig() async {
    final config = await _loadJsonConfig();
    String? apiUrl = config['apiUrl'];
    final elevenLabsApiKey = config['elevenLabsApiKey'] as String?;

    // Auto-detect emulator and use special localhost alias
    // Android emulator needs 10.0.2.2 to access host machine
    // Physical devices use the actual local network IP from config
    if (apiUrl != null && Platform.isAndroid && !kIsWeb) {
      final isEmulator = await _isEmulator();
      if (isEmulator) {
        // Replace any local network IP with emulator's special alias
        apiUrl = apiUrl.replaceFirstMapped(
          RegExp(r'http://[\d.]+:(\d+)'),
          (match) => 'http://10.0.2.2:${match.group(1)}',
        );
        debugPrint('AppConfig: Detected emulator, using $apiUrl');
      } else {
        debugPrint('AppConfig: Detected physical device, using $apiUrl');
      }
    }

    return AppConfig(
      apiUrl: apiUrl,
      elevenLabsApiKey: elevenLabsApiKey,
    );
  }

  static Future<Map<String, dynamic>> _loadJsonConfig() async {
    final data = await rootBundle.loadString(
      'assets/config.json',
    );

    return jsonDecode(data);
  }

  /// Detects if running on Android emulator
  static Future<bool> _isEmulator() async {
    // Check common emulator indicators
    if (Platform.isAndroid) {
      try {
        // Check for emulator-specific properties
        final result = await Process.run('getprop', ['ro.kernel.qemu']);
        if (result.stdout.toString().trim() == '1') {
          return true;
        }

        // Check if device contains emulator identifiers
        final brand = await Process.run('getprop', ['ro.product.brand']);
        final model = await Process.run('getprop', ['ro.product.model']);
        final hardware = await Process.run('getprop', ['ro.hardware']);

        final brandStr = brand.stdout.toString().toLowerCase();
        final modelStr = model.stdout.toString().toLowerCase();
        final hardwareStr = hardware.stdout.toString().toLowerCase();

        if (brandStr.contains('generic') ||
            modelStr.contains('emulator') ||
            modelStr.contains('sdk') ||
            hardwareStr.contains('ranchu') ||
            hardwareStr.contains('goldfish')) {
          return true;
        }
      } catch (e) {
        debugPrint('AppConfig: Could not detect emulator, assuming physical device: $e');
      }
    }
    return false;
  }
}
