import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

import '../analytics/analytics_properties.dart';
import '../config/observability_config.dart';
import 'crash_reporting_service.dart';

/// Integração completa com PostHog (inicialização manual via dart-define).
class PostHogService {
  PostHogService._();
  static final PostHogService instance = PostHogService._();

  bool _initialized = false;

  bool get isEnabled => _initialized && ObservabilityConfig.hasPosthog;

  Future<void> initialize() async {
    if (_initialized) return;

    if (!ObservabilityConfig.hasPosthog) {
      if (kDebugMode) {
        debugPrint('[PostHog] Não configurado — analytics só em debug local.');
      }
      return;
    }

    try {
      final config = PostHogConfig(ObservabilityConfig.posthogApiKey)
        ..host = ObservabilityConfig.posthogHost
        ..debug = ObservabilityConfig.posthogDebug || kDebugMode
        ..captureApplicationLifecycleEvents = true
        ..personProfiles = PostHogPersonProfiles.identifiedOnly
        ..flushAt = 10
        ..flushInterval = const Duration(seconds: 15);

      await Posthog().setup(config);

      await Posthog().register('app_name', 'todoin');
      await Posthog().register('platform', Platform.operatingSystem);
      await Posthog().register(
        'build_mode',
        kReleaseMode ? 'release' : 'debug',
      );

      _initialized = true;
      debugPrint('[PostHog] Inicializado (${ObservabilityConfig.posthogHost}).');
    } catch (e, st) {
      CrashReportingService.instance.recordError(e, st, reason: 'posthog_init');
    }
  }

  void capture(String event, [Map<String, Object?> properties = const {}]) {
    if (!isEnabled) return;

    unawaited(
      Posthog().capture(
        eventName: event,
        properties: sanitizeAnalyticsProperties(properties),
      ),
    );
  }

  void screen(String name, [Map<String, Object?> properties = const {}]) {
    if (!isEnabled) return;

    unawaited(
      Posthog().screen(
        screenName: name,
        properties: sanitizeAnalyticsProperties(properties),
      ),
    );
  }

  Future<void> identifyPro({
    required String planType,
    required bool isPro,
  }) async {
    if (!isEnabled) return;

    try {
      final distinctId = await Posthog().getDistinctId();
      await Posthog().identify(
        userId: distinctId,
        userProperties: {
          'is_pro': isPro,
          'plan_type': planType,
        },
      );
    } catch (e, st) {
      CrashReportingService.instance.recordError(e, st, reason: 'posthog_identify');
    }
  }

  Future<void> flush() async {
    if (!isEnabled) return;
    await Posthog().flush();
  }
}
