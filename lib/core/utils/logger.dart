import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';

class Logger {
  static void d(String message) {
    if (kDebugMode) {
      dev.log('DEBUG: $message', name: 'ACARA');
    }
  }

  static void i(String message) {
    dev.log('INFO: $message', name: 'ACARA');
  }

  static void w(String message) {
    dev.log('WARNING: $message', name: 'ACARA');
  }

  static void e(String message, [Object? error, StackTrace? stackTrace]) {
    dev.log(
      'ERROR: $message',
      name: 'ACARA',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
