import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../config/observability_config.dart';

/// Serviço de crash reporting. Usa Sentry quando `SENTRY_DSN` está configurado.
class CrashReportingService {
  CrashReportingService._();
  static final CrashReportingService instance = CrashReportingService._();

  void recordError(Object error, StackTrace stack, {String? reason}) {
    if (ObservabilityConfig.hasSentry) {
      Sentry.captureException(
        error,
        stackTrace: stack,
        hint: reason != null ? Hint() : null,
      );
    }
    if (kDebugMode) {
      debugPrint('[CrashReporting] $reason: $error\n$stack');
    }
  }

  void log(String message) {
    if (ObservabilityConfig.hasSentry) {
      Sentry.addBreadcrumb(Breadcrumb(message: message));
    }
    if (kDebugMode) {
      debugPrint('[CrashReporting] $message');
    }
  }
}
