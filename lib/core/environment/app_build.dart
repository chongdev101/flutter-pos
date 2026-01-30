class AppBuild {
  // in app_build.dart
  static bool? _overrideSecure;

  static void overrideSecureForTest(bool value) {
    _overrideSecure = value;
  }

  static bool get isSecure {
    if (_overrideSecure != null) return _overrideSecure!;
    return const bool.fromEnvironment('SECURE_BUILD');
  }

  static String get buildType => isSecure ? 'SECURE' : 'DEV';
}
