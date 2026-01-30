import 'rasp_threat_type.dart';

/// Centralized RASP policy decision
/// This file defines how the application should react
/// to each detected security threat.
///
/// Design goals:
/// - No UI logic
/// - No persistence logic
/// - Deterministic & auditable behavior
class RaspPolicy {
  /// Threats that can be recovered by fixing the environment
  /// (e.g. turning off developer mode, setting passcode)
  static bool isRecoverable(RaspThreatType type) {
    switch (type) {
      case RaspThreatType.debug:
        return true; // USB debugging / dev mode off → recoverable

      case RaspThreatType.emulator:
        return true; // switch to real device

      case RaspThreatType.passcode:
        return true; // user can set lock screen

      case RaspThreatType.unofficialStore:
        return true; // uninstall unofficial store

      case RaspThreatType.hook:
        return false; // rooted / hooked device

      case RaspThreatType.appIntegrity:
        return false; // app modified / re-signed

      case RaspThreatType.deviceBinding:
        return false; // bound to another device

      case RaspThreatType.secureHardwareMissing:
        return false; // hardware limitation
    }
  }

  /// Threats that should cause immediate and strict blocking
  static bool isCritical(RaspThreatType type) {
    switch (type) {
      case RaspThreatType.hook:
      case RaspThreatType.appIntegrity:
      case RaspThreatType.deviceBinding:
      case RaspThreatType.secureHardwareMissing:
        return true;

      case RaspThreatType.debug:
      case RaspThreatType.emulator:
      case RaspThreatType.passcode:
      case RaspThreatType.unofficialStore:
        return false;
    }
  }

  /// Human-readable description for audit / logging
  static String description(RaspThreatType type) {
    switch (type) {
      case RaspThreatType.debug:
        return 'Developer mode or USB debugging detected';

      case RaspThreatType.hook:
        return 'Root or runtime hooking detected';

      case RaspThreatType.emulator:
        return 'Application running in emulator';

      case RaspThreatType.appIntegrity:
        return 'Application integrity verification failed';

      case RaspThreatType.unofficialStore:
        return 'Installed from unofficial application store';

      case RaspThreatType.deviceBinding:
        return 'Application device binding mismatch';

      case RaspThreatType.passcode:
        return 'Device lock screen / passcode missing';

      case RaspThreatType.secureHardwareMissing:
        return 'Required secure hardware not available';
    }
  }
}
