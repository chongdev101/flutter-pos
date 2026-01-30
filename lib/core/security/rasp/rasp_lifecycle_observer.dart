import '../storage/security_storage.dart';
import '../dialogs/security_dialog.dart';
import '../../environment/developer_mode_checker.dart';
import 'rasp_policy.dart';
import 'rasp_threat_handler.dart';
import 'rasp_service.dart';
import '../../environment/app_build.dart';
import 'rasp_threat_type.dart';

/// Observer ที่ตรวจสอบ RASP เมื่อ app resume
class RaspLifecycleObserver {
  static Future<void> onAppResumed() async {
    if (!AppBuild.isSecure) {
      print('📱 Lifecycle: Skipped (dev mode)');
      return;
    }

    print('📱 Lifecycle: App resumed - checking threats...');

    // 0️⃣ Reset dialog state
    SecurityDialog.reset();

    // 1️⃣ ถ้า Developer Mode/ADB เปิดอยู่ → block ทันที (ไม่ต้องรอ RASP)
    final devEnabled = await DeveloperModeChecker.isEnabled();
    if (devEnabled) {
      print('📱 Lifecycle: Dev Mode/ADB ON → block immediately');
      await RaspThreatHandler.markAndShow(RaspThreatType.debug);
      return;
    }

    // 2️⃣ ดึง threat จาก storage
    final blockedType = await SecurityStorage.getBlockedThreat();

    // skip unofficialStore ในการทดสอบ (เพราะติดตั้งผ่าน ADB)
    if (blockedType == RaspThreatType.unofficialStore) {
      print('📱 Lifecycle: Skipping unofficialStore (testing)');
    } else if (blockedType != null && !RaspPolicy.isRecoverable(blockedType)) {
      print('📱 Lifecycle: Non-recoverable threat: $blockedType');
      SecurityDialog.show(
        title: 'Security Alert',
        message: 'ไม่สามารถใช้งานแอปในสภาพแวดล้อมนี้ได้',
      );
      return;
    }

    // 3️⃣ Reset handler state ก่อน restart
    RaspThreatHandler.reset();

    // 4️⃣ Restart RASP → re-scan
    print('📱 Lifecycle: Restarting RASP...');
    await RaspService.instance.restart();

    // 5️⃣ รอ scan
    print('📱 Lifecycle: Waiting for RASP scan...');
    await Future.delayed(const Duration(seconds: 2));

    // 6️⃣ ถ้ามี threat recoverable ใน storage และ RASP ไม่ detect → clear storage
    if (blockedType != null && blockedType != RaspThreatType.unofficialStore && !RaspThreatHandler.hasThreat) {
      print('📱 Lifecycle: Threat cleared → clearing storage');
      await SecurityStorage.clearBlocked();
    }
  }
}
