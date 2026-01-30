import 'package:get/get.dart';
import '../dialogs/security_dialog.dart';
import '../storage/security_storage.dart';
import '../../environment/app_build.dart';
import '../../environment/developer_mode_checker.dart';
import 'rasp_policy.dart';
import 'rasp_service.dart';
import 'rasp_threat_handler.dart';
import 'rasp_threat_type.dart';

/// Central coordinator for RASP flows using GetX
class RaspController extends GetxController {
  RaspController(this._raspService);

  final RaspService _raspService;

  /// Called on app startup (after first frame)
  Future<void> onAppStart(RaspThreatType? blockedType) async {
    if (!AppBuild.isSecure) {
      print('❌ RASP SKIPPED - Not in secure flavor');
      return;
    }

    print('🔒 RASP Init via GetX...');

    // If Dev mode/ADB on → block immediately
    final devEnabled = await DeveloperModeChecker.isEnabled();
    if (devEnabled) {
      print('🚫 Dev Mode/ADB ON → block');
      await RaspThreatHandler.markAndShow(RaspThreatType.debug);
      return;
    }

    // Non-recoverable threat persisted
    if (blockedType != null && !RaspPolicy.isRecoverable(blockedType)) {
      _showSecurityAlert();
      return;
    }

    // Recoverable threat persisted → clear
    if (blockedType != null && RaspPolicy.isRecoverable(blockedType)) {
      print('✅ Clear recoverable threat from storage');
      await SecurityStorage.clearBlocked();
    }

    await _raspService.initialize();
    print('⏳ Waiting for RASP scan...');
    await Future.delayed(const Duration(seconds: 2));
  }

  /// Called when app resumes
  Future<void> onAppResumed() async {
    if (!AppBuild.isSecure) return;

    SecurityDialog.reset();

    // Dev mode check
    final devEnabled = await DeveloperModeChecker.isEnabled();
    if (devEnabled) {
      print('📱 Resume: Dev Mode ON → block');
      await RaspThreatHandler.markAndShow(RaspThreatType.debug);
      return;
    }

    final blockedType = await SecurityStorage.getBlockedThreat();
    if (blockedType != null && !RaspPolicy.isRecoverable(blockedType)) {
      _showSecurityAlert();
      return;
    }

    // Recoverable threat persisted but env clean → clear
    if (blockedType != null && RaspPolicy.isRecoverable(blockedType)) {
      print('📱 Resume: Clear recoverable threat');
      await SecurityStorage.clearBlocked();
    }

    RaspThreatHandler.reset();
    await _raspService.restart();
    await Future.delayed(const Duration(seconds: 2));
  }

  void _showSecurityAlert() {
    SecurityDialog.show(
      title: 'Security Alert',
      message: 'ไม่สามารถใช้งานแอปในสภาพแวดล้อมนี้ได้',
    );
  }
}
