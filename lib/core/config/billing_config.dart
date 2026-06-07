/// Configuração do RevenueCat.
/// Defina as chaves via --dart-define na build de produção:
///   --dart-define=REVENUECAT_APPLE_API_KEY=appl_xxx
///   --dart-define=REVENUECAT_GOOGLE_API_KEY=goog_xxx
abstract class BillingConfig {
  static const appleApiKey = String.fromEnvironment(
    'REVENUECAT_APPLE_API_KEY',
    defaultValue: '',
  );

  static const googleApiKey = String.fromEnvironment(
    'REVENUECAT_GOOGLE_API_KEY',
    defaultValue: '',
  );

  /// ID do entitlement configurado no dashboard RevenueCat.
  static const entitlementId = 'pro';

  static bool get isConfigured =>
      isAppleKeyConfigured || isGoogleKeyConfigured;

  static bool get isAppleKeyConfigured =>
      appleApiKey.isNotEmpty && appleApiKey.startsWith('appl_');

  static bool get isGoogleKeyConfigured =>
      googleApiKey.isNotEmpty && googleApiKey.startsWith('goog_');
}
