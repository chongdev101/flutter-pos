import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pos_android/core/security/rasp/rasp_threat_handler.dart';
import 'package:pos_android/core/security/rasp/rasp_threat_type.dart';
import 'package:pos_android/core/security/storage/security_storage.dart';
import 'package:pos_android/core/environment/app_build.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SecurityStorage.clear();
    AppBuild.overrideSecureForTest(true);
    RaspThreatHandler.resetForTest();
  });

  test('Recoverable threat should NOT be stored as blocked', () async {
    await RaspThreatHandler.handle(RaspThreatType.debug);

    final blocked = await SecurityStorage.getBlockedThreat();

    expect(blocked, null);
  });

  test('Critical threat SHOULD be stored as blocked', () async {
    await RaspThreatHandler.handle(RaspThreatType.hook);

    final blocked = await SecurityStorage.getBlockedThreat();

    expect(blocked, RaspThreatType.hook);
  });
}
