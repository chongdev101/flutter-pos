import 'package:freerasp/freerasp.dart';
import '../../environment/app_build.dart';

class RaspConfig {
  static TalsecConfig build() {
    return TalsecConfig(
      androidConfig: AndroidConfig(
        packageName: 'com.chongdev.pos_android',
        signingCertHashes: [
          // SHA256 in Base64 format (from pos-release.jks)
          // HEX: 49:6A:E8:A9:F6:7E:64:61:F3:00:EF:02:76:A4:DD:22:08:99:E4:A2:6E:62:74:76:E1:52:04:6D:CD:B6:B9:32
          'SWroqfZ+ZGHzAO8CdqTdIgiZ5KJuYnR24VIEbc22uTI=',
        ],
        supportedStores: [
          'com.android.vending',  // Google Play Store
          // Allow sideload for testing (remove in production)
        ],
      ),

      iosConfig: IOSConfig(
        bundleIds: [
          'com.chongdev.pos_android',
        ],
        teamId: 'YOUR_TEAM_ID',
      ),

      watcherMail: 'security@yourcompany.com',

      /// dev=false → strict
      /// dev=true  → log only
      isProd: AppBuild.isSecure,
    );
  }
}
