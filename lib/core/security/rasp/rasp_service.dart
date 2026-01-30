import 'package:freerasp/freerasp.dart';
import 'rasp_config.dart';
import 'rasp_threat_handler.dart';
import 'rasp_threat_type.dart';

class RaspService {
  RaspService._();

  static final RaspService instance = RaspService._();

  bool _isStarted = false;

  Future<void> initialize() async {
    print('🔒 RaspService: Initializing...');
    final config = RaspConfig.build();

    // attach listener -> NOT showing UI here, only forward to handler
    Talsec.instance.attachListener(
      ThreatCallback(
        onAppIntegrity: () =>
            RaspThreatHandler.handle(RaspThreatType.appIntegrity),
        onDebug: () => RaspThreatHandler.handle(RaspThreatType.debug),
        onHooks: () => RaspThreatHandler.handle(RaspThreatType.hook),
        onSimulator: () => RaspThreatHandler.handle(RaspThreatType.emulator),
        onUnofficialStore: () {
          print('⚠️ RASP: unofficialStore detected → skipped (ADB install false positive)');
        },
        onDeviceBinding: () =>
            RaspThreatHandler.handle(RaspThreatType.deviceBinding),
        onPasscode: () => RaspThreatHandler.handle(RaspThreatType.passcode),
        onSecureHardwareNotAvailable: () => RaspThreatHandler.handle(
          RaspThreatType.secureHardwareMissing,
        ),
      ),
    );

    // Start RASP
    if (!_isStarted) {
      await Talsec.instance.start(config);
      _isStarted = true;
      print('✅ RaspService: Started successfully');
    } else {
      print('✅ RaspService: Already started, listener re-attached');
    }
  }

  /// Re-start RASP เพื่อ re-scan threats (ใช้เมื่อ app resume)
  Future<void> restart() async {
    print('🔄 RaspService: Restarting...');
    final config = RaspConfig.build();

    // Re-attach listener
    Talsec.instance.attachListener(
      ThreatCallback(
        onAppIntegrity: () =>
            RaspThreatHandler.handle(RaspThreatType.appIntegrity),
        onDebug: () => RaspThreatHandler.handle(RaspThreatType.debug),
        onHooks: () => RaspThreatHandler.handle(RaspThreatType.hook),
        onSimulator: () => RaspThreatHandler.handle(RaspThreatType.emulator),
        onUnofficialStore: () {
          print('⚠️ RASP: unofficialStore detected → skipped (ADB install false positive)');
        },
        onDeviceBinding: () =>
            RaspThreatHandler.handle(RaspThreatType.deviceBinding),
        onPasscode: () => RaspThreatHandler.handle(RaspThreatType.passcode),
        onSecureHardwareNotAvailable: () => RaspThreatHandler.handle(
          RaspThreatType.secureHardwareMissing,
        ),
      ),
    );

    // Try to start again (may or may not trigger re-scan)
    try {
      await Talsec.instance.start(config);
      print('✅ RaspService: Restarted successfully');
    } catch (e) {
      print('⚠️ RaspService: Restart failed (expected if already started): $e');
    }
  }

  bool get isStarted => _isStarted;
}
