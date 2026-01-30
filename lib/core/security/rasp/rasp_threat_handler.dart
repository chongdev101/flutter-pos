import '../../../app/app_navigator.dart';
import '../dialogs/security_dialog.dart';
import 'rasp_threat_type.dart';

class RaspThreatHandler {
  // store pending single/latest threat (สามารถเปลี่ยนเป็น queue ได้ถ้าต้องการ)
  static RaspThreatType? _pending;

  static void handle(RaspThreatType type) {
    // store pending threat (do not show dialog here)
    _pending = type;

    // if UI already ready we can try to show immediately via navigatorKey
    // but safer approach is to require UI to call `showPendingIfAny` after frame
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
}
