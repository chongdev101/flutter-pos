import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/app.dart';
import 'core/environment/app_build.dart';
import 'core/security/storage/security_storage.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Debug: แสดง build flavor
  const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'UNKNOWN');
  print('═══════════════════════════════════════');
  print('🔧 Build Flavor: $flavor');
  print('🔧 Is Secure: ${AppBuild.isSecure}');
  print('═══════════════════════════════════════');

  final blockedType = await SecurityStorage.getBlockedThreat();
  print('⚠️ Previous Threat: $blockedType');

  runApp(MyApp(blockedType: blockedType));
}
