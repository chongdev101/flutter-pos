import 'package:flutter_test/flutter_test.dart';
import 'package:pos_android/core/security/rasp/rasp_policy.dart';
import 'package:pos_android/core/security/rasp/rasp_threat_type.dart';

void main() {
  group('RaspPolicy', () {
    test('Recoverable threats should be recoverable', () {
      expect(RaspPolicy.isRecoverable(RaspThreatType.debug), true);
      expect(RaspPolicy.isRecoverable(RaspThreatType.emulator), true);
      expect(RaspPolicy.isRecoverable(RaspThreatType.passcode), true);
      expect(RaspPolicy.isRecoverable(RaspThreatType.unofficialStore), true);
    });

    test('Critical threats should NOT be recoverable', () {
      expect(RaspPolicy.isRecoverable(RaspThreatType.hook), false);
      expect(RaspPolicy.isRecoverable(RaspThreatType.appIntegrity), false);
      expect(RaspPolicy.isRecoverable(RaspThreatType.deviceBinding), false);
      expect(RaspPolicy.isRecoverable(RaspThreatType.secureHardwareMissing),
          false);
    });

    test('Critical threats should be marked as critical', () {
      expect(RaspPolicy.isCritical(RaspThreatType.hook), true);
      expect(RaspPolicy.isCritical(RaspThreatType.appIntegrity), true);
      expect(RaspPolicy.isCritical(RaspThreatType.deviceBinding), true);
      expect(RaspPolicy.isCritical(RaspThreatType.secureHardwareMissing), true);
    });

    test('Recoverable threats should NOT be marked as critical', () {
      expect(RaspPolicy.isCritical(RaspThreatType.debug), false);
      expect(RaspPolicy.isCritical(RaspThreatType.emulator), false);
      expect(RaspPolicy.isCritical(RaspThreatType.passcode), false);
      expect(RaspPolicy.isCritical(RaspThreatType.unofficialStore), false);
    });
  });
}
