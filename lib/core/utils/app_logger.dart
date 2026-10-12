import 'dart:developer' as dev;
import '../config/env_config.dart';

/// Lightweight application logger
class AppLogger {
  AppLogger._();

  static void d(String message, [String? tag]) {
    if (EnvConfig.isDebug) {
      dev.log(message, name: tag ?? 'DEBUG');
    }
  }

  static void i(String message, [String? tag]) {
    dev.log(message, name: tag ?? 'INFO');
  }

  static void w(String message, [String? tag]) {
    dev.log('⚠️ $message', name: tag ?? 'WARN');
  }

  static void e(String message, [dynamic error, StackTrace? stackTrace, String? tag]) {
    dev.log(
      '❌ $message',
      name: tag ?? 'ERROR',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
