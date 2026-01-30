import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pos_android/core/security/storage/security_storage.dart';
import 'package:pos_android/core/security/rasp/rasp_threat_type.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Should store and retrieve blocked threat type', () async {
    await SecurityStorage.markBlocked(RaspThreatType.debug);

    final blocked = await SecurityStorage.getBlockedThreat();

    expect(blocked, RaspThreatType.debug);
  });

  test('Should clear blocked threat', () async {
    await SecurityStorage.markBlocked(RaspThreatType.hook);
    await SecurityStorage.clear();

    final blocked = await SecurityStorage.getBlockedThreat();

    expect(blocked, null);
  });
}
