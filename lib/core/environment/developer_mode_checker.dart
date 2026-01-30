import 'package:flutter/services.dart';

class DeveloperModeChecker {
  static const _channel = MethodChannel('security/dev_mode');

  /// Returns true if ADB or Developer Options are enabled (Android only)
  static Future<bool> isEnabled() async {
    try {
      final result = await _channel.invokeMethod<bool>('isDevModeEnabled');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }
}
