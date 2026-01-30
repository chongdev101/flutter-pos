import 'package:freerasp/freerasp.dart';

class RaspConfig {
  static TalsecConfig build() {
    return TalsecConfig(
      androidConfig: AndroidConfig(
        packageName: 'com.chongdev.pos_android_101',
        signingCertHashes: [
          'YOUR_RELEASE_SHA256_BASE64',
        ],
        supportedStores: [
          'com.android.vending',
        ],
      ),

      iosConfig: IOSConfig(
        bundleIds: [
          'com.chongdev.pos_android_101',
        ],
        teamId: 'YOUR_TEAM_ID',
      ),

      watcherMail: 'security@yourcompany.com',

      /// dev=false → strict
      /// dev=true  → log only
      isProd: false,
    );
  }
}
