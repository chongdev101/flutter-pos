import 'package:freerasp/freerasp.dart';
import 'rasp_config.dart';
import 'rasp_threat_handler.dart';
import 'rasp_threat_type.dart';

class RaspService {
  RaspService._();

  static final RaspService instance = RaspService._();

  Future<void> initialize() async {
    final config = RaspConfig.build();

    // attach listener -> NOT showing UI here, only forward to handler
    Talsec.instance.attachListener(
      ThreatCallback(
        onAppIntegrity: () =>
            RaspThreatHandler.handle(RaspThreatType.appIntegrity),
        onDebug: () => RaspThreatHandler.handle(RaspThreatType.debug),
        onHooks: () => RaspThreatHandler.handle(RaspThreatType.hook),
        onSimulator: () => RaspThreatHandler.handle(RaspThreatType.emulator),
        onUnofficialStore: () =>
            RaspThreatHandler.handle(RaspThreatType.unofficialStore),
        onDeviceBinding: () =>
            RaspThreatHandler.handle(RaspThreatType.deviceBinding),
        onPasscode: () => RaspThreatHandler.handle(RaspThreatType.passcode),
        onSecureHardwareNotAvailable: () => RaspThreatHandler.handle(
          RaspThreatType.secureHardwareMissing,
        ),
      ),
    );

    await Talsec.instance.start(config);
  }
}
