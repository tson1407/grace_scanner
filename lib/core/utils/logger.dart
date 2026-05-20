import 'dart:developer' as dev;

/// Simple logging wrapper.
class AppLogger {
  AppLogger._();

  static void debug(String message, {String tag = 'ScanFlow'}) {
    dev.log(message, name: tag, level: 500);
  }

  static void info(String message, {String tag = 'ScanFlow'}) {
    dev.log(message, name: tag, level: 800);
  }

  static void warning(String message, {String tag = 'ScanFlow'}) {
    dev.log(message, name: tag, level: 900);
  }

  static void error(String message, {String tag = 'ScanFlow', Object? error, StackTrace? stackTrace}) {
    dev.log(message, name: tag, level: 1000, error: error, stackTrace: stackTrace);
  }
}
