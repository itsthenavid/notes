// lib/utils/app_logger.dart

import 'package:flutter/foundation.dart';

enum LogLevel { info, warning, error, success, debug }

class AppLogger {
  AppLogger._();

  static const bool _enabled = kDebugMode;
  static const String _prefix = '📝 Notes App';

  static void info(String message, [String? tag]) {
    _log(LogLevel.info, message, tag);
  }

  static void warning(String message, [String? tag]) {
    _log(LogLevel.warning, message, tag);
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (!_enabled) return;

    final timestamp = _getTimestamp();
    final tagStr = 'ERROR';
    print('❌ $_prefix [$timestamp] $tagStr: $message');

    if (error != null) {
      print('   └─ Error: $error');
    }
    if (stackTrace != null) {
      print('   └─ Stack trace:\n$stackTrace');
    }
  }

  static void success(String message, [String? tag]) {
    _log(LogLevel.success, message, tag);
  }

  static void debug(String message, [String? tag]) {
    _log(LogLevel.debug, message, tag);
  }

  static void _log(LogLevel level, String message, [String? tag]) {
    if (!_enabled) return;

    final timestamp = _getTimestamp();
    final emoji = _getEmoji(level);
    final levelName = tag ?? level.name.toUpperCase();

    print('$emoji $_prefix [$timestamp] $levelName: $message');
  }

  static String _getTimestamp() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}';
  }

  static String _getEmoji(LogLevel level) {
    switch (level) {
      case LogLevel.info:
        return '📘';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
      case LogLevel.success:
        return '✅';
      case LogLevel.debug:
        return '🔍';
    }
  }

  static void separator([String char = '─']) {
    if (!_enabled) return;
    print(char * 80);
  }

  static void section(String title) {
    if (!_enabled) return;
    separator('═');
    print('║ $title');
    separator('═');
  }
}
