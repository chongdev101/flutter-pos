import '../../../app/app_navigator.dart';
import '../dialogs/security_dialog.dart';
import 'rasp_policy.dart';
import 'rasp_threat_type.dart';
import '../../environment/app_build.dart';
import '../storage/security_storage.dart';

class RaspThreatHandler {
  static RaspThreatType? _pending;

  static Future<void> handle(RaspThreatType type) async {
    // 1️⃣ dev / non-secure build → ไม่ enforce
    if (!AppBuild.isSecure) {
      return;
    }

    // 2️⃣ ป้องกัน event ซ้ำ (🔥 บรรทัดที่คุณถาม)
    if (_pending == type) {
      return;
    }

    // 3️⃣ enforce policy
    if (RaspPolicy.isCritical(type)) {
      await SecurityStorage.markBlocked(type);
    }

    // 4️⃣ set pending เพื่อรอ UI
    _pending = type;
    tryShowIfUiReady();
  }

  static void tryShowIfUiReady() {
    final context = navigatorKey.currentContext;
    if (context == null) return;
    showPendingIfAny();
  }

  static void showPendingIfAny() {
    final type = _pending;
    if (type == null) return;
    _pending = null;

    // map to title/message
    String title;
    String message;
    switch (type) {
      case RaspThreatType.debug:
        title = 'Debug Detected';
        message = 'ไม่อนุญาตให้เปิด USB Debugging';
        break;
      case RaspThreatType.hook:
        title = 'Device Compromised';
        message = 'ตรวจพบการดัดแปลงระบบหรือแอป';
        break;
      case RaspThreatType.emulator:
        title = 'Simulator Detected';
        message = 'ไม่อนุญาตให้ใช้งานบน Emulator';
        break;
      case RaspThreatType.appIntegrity:
        title = 'App Integrity Failed';
        message = 'แอปถูกแก้ไขหรือ re-sign';
        break;
      default:
        title = 'Security Alert';
        message = 'ตรวจพบความผิดปกติด้านความปลอดภัย';
    }

    SecurityDialog.show(title: title, message: message);
  }

  static void resetForTest() {
    _pending = null;
  }
}
