import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/environment/app_build.dart';
import 'core/security/rasp/rasp_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());

  // initialize RASP only after first frame (UI ready)
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (AppBuild.isSecure) {
      // do not await here — let initialize run async in background
      RaspService.instance.initialize();
    }
  });
}
