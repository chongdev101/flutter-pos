class AppBuild {
  /// true เฉพาะ secure flavor เท่านั้น
  static const bool isSecure =
      bool.fromEnvironment('SECURE_BUILD', defaultValue: false);
}
