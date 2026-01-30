import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'bindings/global_binding.dart';
import '../features/home/home_page.dart';
import '../core/security/rasp/rasp_threat_type.dart';
import '../core/security/rasp/rasp_controller.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key, this.blockedType});
  final RaspThreatType? blockedType;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    // Start RASP after binding ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<RaspController>().onAppStart(widget.blockedType);
    });

    _lifecycleListener = AppLifecycleListener(
      onResume: () => Get.find<RaspController>().onAppResumed(),
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'POS',
      debugShowCheckedModeBanner: false,
      initialBinding: GlobalBinding(),
      initialRoute: AppRoutes.home,
      getPages: AppPages.pages,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(),
    );
  }
}
