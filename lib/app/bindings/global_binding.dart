import 'package:get/get.dart';
import '../../core/security/rasp/rasp_service.dart';
import '../../core/security/rasp/rasp_controller.dart';

class GlobalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RaspService>(() => RaspService());
    Get.lazyPut<RaspController>(() => RaspController(Get.find<RaspService>()));
  }
}
