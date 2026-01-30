import 'package:get/get.dart';
import '../../features/home/home_page.dart';
import '../../features/rasp_poc/rasp_flutter_page.dart';
import 'app_routes.dart';
import '../bindings/global_binding.dart';

class AppPages {
  static final pages = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
      binding: GlobalBinding(),
    ),
    GetPage(
      name: AppRoutes.rasp,
      page: () => const RASPFlutterPage(),
      binding: GlobalBinding(),
    ),
  ];
}
