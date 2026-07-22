import 'package:flutter/foundation.dart';

/// Crash reporting wrapper service for MyVault.
class CrashReportingService {
  CrashReportingService._();
  static final CrashReportingService instance = CrashReportingService._();

  Future<void> init() async {
    FlutterError.onError = (FlutterErrorDetails details) {
      debugPrint('[Crashlytics] Fatal Error: ${details.exceptionAsString()}');
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('[Crashlytics] Unhandled Async Error: $error');
      return true;
    };
  }

  Future<void> setStudentId(String? studentId) async {
    debugPrint('[Crashlytics] User Identifier set to: $studentId');
  }

  void log(String message) => debugPrint('[Crashlytics Log] $message');

  Future<void> recordNonFatal(
    Object error,
    StackTrace stack, {
    String? reason,
  }) async {
    debugPrint('[Crashlytics NonFatal] Error: $error, Reason: $reason');
  }
}
