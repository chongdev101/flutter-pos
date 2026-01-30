import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/environment/app_build.dart';
import 'core/security/rasp/rasp_policy.dart';
import 'core/security/rasp/rasp_service.dart';
import 'core/security/storage/security_storage.dart';
import 'core/security/dialogs/security_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final blockedType = await SecurityStorage.getBlockedThreat();

  runApp(const MyApp());

  // initialize RASP only after first frame (UI ready)
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!AppBuild.isSecure) {
      return;
    }

    // 🔒 เคยโดน block มาก่อน
    if (blockedType != null) {
      // ❌ threat ร้ายแรง → block ต่อทันที
      if (!RaspPolicy.isRecoverable(blockedType)) {
        SecurityDialog.show(
          title: 'Security Alert',
          message: 'ไม่สามารถใช้งานแอปในสภาพแวดล้อมนี้ได้',
        );
        return;
      }

      // 🔁 threat แก้ไขได้ → ให้ RASP ตรวจใหม่
      RaspService.instance.initialize();
      return;
    }

    // 🟢 ไม่เคยโดน block → init ปกติ
    RaspService.instance.initialize();
  });
}
