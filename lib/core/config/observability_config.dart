/// Configuração de observabilidade via --dart-define.
abstract class ObservabilityConfig {
  static const sentryDsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: '',
  );

  static const posthogApiKey = String.fromEnvironment(
    'POSTHOG_API_KEY',
    defaultValue: '',
  );

  static const posthogHost = String.fromEnvironment(
    'POSTHOG_HOST',
    defaultValue: 'https://us.i.posthog.com',
  );

  /// Força logs do SDK PostHog mesmo em release (útil para validar integração).
  static const posthogDebug = bool.fromEnvironment(
    'POSTHOG_DEBUG',
    defaultValue: false,
  );

  static bool get hasSentry => sentryDsn.isNotEmpty;
  static bool get hasPosthog => posthogApiKey.isNotEmpty;
}
