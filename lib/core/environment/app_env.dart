enum AppEnv { dev, uat, prod }

class AppEnvironment {
  static AppEnv current = AppEnv.dev;

  static bool get enableRaspDialog =>
      current != AppEnv.dev;
}
