import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/environment/app_build.dart';
import 'core/environment/developer_mode_checker.dart';
import 'core/security/rasp/rasp_policy.dart';
import 'core/security/rasp/rasp_service.dart';
import 'core/security/rasp/rasp_threat_handler.dart';
import 'core/security/rasp/rasp_threat_type.dart';
import 'core/security/storage/security_storage.dart';
import 'core/security/dialogs/security_dialog.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Debug: แสดง build flavor
  const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'UNKNOWN');
  print('═══════════════════════════════════════');
  print('🔧 Build Flavor: $flavor');
  print('🔧 Is Secure: ${AppBuild.isSecure}');
  print('═══════════════════════════════════════');

  final blockedType = await SecurityStorage.getBlockedThreat();
  print('⚠️ Previous Threat: $blockedType');

  runApp(const MyApp());

  // initialize RASP only after first frame (UI ready)
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    if (!AppBuild.isSecure) {
      print('❌ RASP SKIPPED - Not in secure flavor');
      return;
    }

    print('🔒 Starting RASP initialization...');

    // 0️⃣ ถ้า Developer Mode/ADB เปิดอยู่ → block ทันที และ mark storage
    final devEnabled = await DeveloperModeChecker.isEnabled();
    if (devEnabled) {
      print('🚫 Developer Mode/ADB is ON → block immediately');
      await RaspThreatHandler.markAndShow(RaspThreatType.debug);
      return;
    }

    // 1️⃣ ถ้ามี blocked threat ที่ไม่สามารถแก้ไขได้ → block ถาวร
    if (blockedType != null && !RaspPolicy.isRecoverable(blockedType)) {
      print('🚫 Non-recoverable threat found: $blockedType');
      SecurityDialog.show(
        title: 'Security Alert',
        message: 'ไม่สามารถใช้งานแอปในสภาพแวดล้อมนี้ได้',
      );
      return;
    }

    // 2️⃣ ถ้ามี blocked threat แบบ recoverable → ให้ RASP ตรวจใหม่ (ยกเว้น unofficialStore)
    if (blockedType != null && blockedType != RaspThreatType.unofficialStore) {
      print('🔄 Recoverable threat found: $blockedType → waiting for RASP re-check');
    }

    // 🟢 Init RASP
    await RaspService.instance.initialize();

    // รอให้ RASP scan เสร็จ (ประมาณ 2 วินาที)
    print('⏳ Waiting for RASP scan...');
    await Future.delayed(const Duration(seconds: 2));

    // ตรวจสอบผลลัพธ์สำหรับ recoverable threat (ยกเว้น unofficialStore)
    if (blockedType != null && blockedType != RaspThreatType.unofficialStore) {
      if (RaspThreatHandler.hasThreat) {
        print('✅ RASP detected threat, modal will show');
      } else {
        print('✅ Threat cleared! No detection from RASP');
        await SecurityStorage.clearBlocked();
      }
    }
  });
}
