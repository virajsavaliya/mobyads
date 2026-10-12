/// Environment configuration
enum Environment { dev, staging, prod }

class EnvConfig {
  EnvConfig._();

  static Environment current = Environment.dev;

  static String get baseUrl {
    switch (current) {
      case Environment.dev:
        return 'https://api-dev.mobyads.com/api/v1';
      case Environment.staging:
        return 'https://api-staging.mobyads.com/api/v1';
      case Environment.prod:
        return 'https://api.mobyads.com/api/v1';
    }
  }

  static bool get isDebug => current == Environment.dev;
}
