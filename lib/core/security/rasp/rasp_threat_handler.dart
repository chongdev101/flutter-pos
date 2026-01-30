import '../dialogs/security_dialog.dart';
import 'rasp_threat_type.dart';
import 'rasp_policy.dart';
import '../../environment/app_build.dart';
import '../storage/security_storage.dart';

class RaspThreatHandler {
  static RaspThreatType? _pending;
  static final Set<RaspThreatType> _detectedThreats = {};
  static RaspThreatType? _lastThreat; // เก็บ threat ล่าสุดสำหรับ resume

  static Future<void> handle(RaspThreatType type) async {
    print('🚨 Threat Detected: $type');

    // 1️⃣ dev / non-secure build → ไม่ enforce
    if (!AppBuild.isSecure) {
      print('   → Skipped (dev mode)');
      return;
    }

    // 🧪 Ignore unofficialStore (ติดตั้งผ่าน ADB ทำให้ false positive)
    if (type == RaspThreatType.unofficialStore) {
      print('   → Skipped (unofficialStore ignored to avoid false positive)');
      return;
    }

    // 2️⃣ เก็บ threat ที่ตรวจพบ
    _detectedThreats.add(type);
    _lastThreat = type; // เก็บไว้สำหรับ resume

    // 3️⃣ ป้องกัน event ซ้ำขณะที่กำลังแสดง modal
    if (_pending == type) {
      print('   → Skipped (duplicate while showing modal)');
      return;
    }

    // 4️⃣ save threat ลง storage เฉพาะ non-recoverable (critical)
    if (!RaspPolicy.isRecoverable(type)) {
      print('   → Saving NON-recoverable threat to storage...');
      await SecurityStorage.markBlocked(type);
    }

    // 5️⃣ set pending เพื่อรอ UI
    _pending = type;
    print('   → Showing modal...');
    tryShowIfUiReady();
  }

  static void tryShowIfUiReady() {
    showPendingIfAny();
  }

  static void showPendingIfAny() {
    final type = _pending;
    if (type == null) return;
    _pending = null;

    _showModal(type);
  }

  /// แสดง modal สำหรับ threat ล่าสุด (ใช้เมื่อ app resume)
  static void showLastThreatIfAny() {
    if (!AppBuild.isSecure) return;

    final type = _lastThreat;
    if (type == null) {
      print('📱 Resume: No threat to show');
      return;
    }

    print('📱 Resume: Showing last threat: $type');
    _showModal(type);
  }

  static void _showModal(RaspThreatType type) {
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

  /// Reset pending เพื่อให้ RASP สามารถแสดง modal ใหม่ได้ (ไม่ clear lastThreat)
  static void resetPending() {
    print('🔄 RaspThreatHandler: Resetting pending');
    _pending = null;
  }

  /// Reset ทุกอย่าง (ใช้ตอน clear threat ได้แล้ว)
  static void reset() {
    print('🔄 RaspThreatHandler: Resetting all states');
    _pending = null;
    _detectedThreats.clear();
    _lastThreat = null;
  }

  /// ตรวจสอบว่ามี threat ประเภทนี้ถูกตรวจพบหรือไม่
  static bool hasDetected(RaspThreatType type) {
    return _detectedThreats.contains(type);
  }

  /// ตรวจสอบว่ามี threat ค้างอยู่หรือไม่
  static bool get hasThreat => _lastThreat != null;

  /// แสดง modal สำหรับ threat ที่โหลดจาก storage (ใช้ตอนเปิดแอพใหม่)
  static void handleFromStorage(RaspThreatType type) {
    print('📦 Handling threat from storage: $type');

    if (!AppBuild.isSecure) {
      print('   → Skipped (dev mode)');
      return;
    }

    // เก็บไว้ใน memory
    _detectedThreats.add(type);
    _lastThreat = type;

    // แสดง modal ทันที
    _showModal(type);
  }

  /// Manual mark + show (ใช้กรณีตรวจเอง เช่น Developer Mode checker)
  static Future<void> markAndShow(RaspThreatType type) async {
    _detectedThreats.add(type);
    _lastThreat = type;
    await SecurityStorage.markBlocked(type);
    _showModal(type);
  }

  /// แสดง modal สำหรับ threat (alias ของ handleFromStorage)
  static void showModalForThreat(RaspThreatType type) {
    handleFromStorage(type);
  }
}
