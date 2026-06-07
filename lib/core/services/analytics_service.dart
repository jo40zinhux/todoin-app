import 'package:flutter/foundation.dart';

import '../config/observability_config.dart';
import 'posthog_service.dart';

/// Serviço de analytics do toDoin.
/// Envia eventos ao PostHog quando `POSTHOG_API_KEY` está configurada.
class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  final PostHogService _posthog = PostHogService.instance;

  Future<void> initialize() => _posthog.initialize();

  bool get isPostHogEnabled => _posthog.isEnabled;

  void track(String event, [Map<String, Object?> properties = const {}]) {
    if (kDebugMode) {
      debugPrint('[Analytics] $event ${properties.isEmpty ? '' : properties}');
    }
    _posthog.capture(event, properties);
  }

  void screen(String name, [Map<String, Object?> properties = const {}]) {
    if (kDebugMode) {
      debugPrint('[Analytics] screen_view {$name}');
    }
    _posthog.screen(name, properties);
  }

  Future<void> syncUserProfile({
    required bool isPro,
    required String planType,
  }) =>
      _posthog.identifyPro(planType: planType, isPro: isPro);

  void taskCreated() => track('task_created');
  void taskCompleted() => track('task_completed');
  void backupExported() => track('backup_exported');
  void backupImported() => track('backup_imported');
  void timerStarted({required int seconds}) =>
      track('timer_started', {'seconds': seconds});
  void cantStartUsed({required String blocker}) =>
      track('cant_start_used', {'blocker': blocker});
  void paywallShown({required String trigger}) =>
      track('paywall_shown', {'trigger': trigger});
  void purchaseStarted({required String planId}) =>
      track('purchase_started', {'plan_id': planId});
  void purchaseCompleted({required String planId}) =>
      track('purchase_completed', {'plan_id': planId});
  void onboardingCompleted() => track('onboarding_completed');

  void cloudSyncCompleted({required String result}) =>
      track('cloud_sync_completed', {'result': result});

  void cloudSyncEnabled({required bool enabled}) =>
      track('cloud_sync_toggled', {'enabled': enabled});

  void aiSubtasksGenerated({required String source}) =>
      track('ai_subtasks_generated', {'source': source});

  /// Evento de verificação — dispara no startup quando PostHog está ativo.
  void appOpened() {
    track('app_opened', {
      'posthog_configured': ObservabilityConfig.hasPosthog,
      'posthog_enabled': isPostHogEnabled,
    });
  }
}
