import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../config/billing_config.dart';
import '../../features/billing/domain/entities/billing_result.dart';
import '../../features/billing/domain/entities/entitlement.dart';
import 'analytics_service.dart';
import 'crash_reporting_service.dart';

/// Integração com RevenueCat. Sem API key configurada, opera em modo dev
/// (compras delegadas ao repositório local).
class BillingService {
  BillingService._();
  static final BillingService instance = BillingService._();

  bool _initialized = false;
  bool _available = false;

  bool get isStoreAvailable => _available && _hasValidApiKeyForPlatform();

  bool _hasValidApiKeyForPlatform() {
    if (Platform.isIOS) return BillingConfig.isAppleKeyConfigured;
    if (Platform.isAndroid) return BillingConfig.isGoogleKeyConfigured;
    return false;
  }

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    if (!_hasValidApiKeyForPlatform()) {
      debugPrint(
        '[BillingService] RevenueCat não configurado — modo dev/local.',
      );
      return;
    }

    try {
      final apiKey = Platform.isIOS
          ? BillingConfig.appleApiKey
          : BillingConfig.googleApiKey;

      await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.warn);
      await Purchases.configure(PurchasesConfiguration(apiKey));
      _available = true;
      debugPrint('[BillingService] RevenueCat inicializado.');
    } catch (e, st) {
      _available = false;
      _logBillingIssue('billing_init', e, st);
    }
  }

  /// Sincroniza entitlement a partir da loja (startup / restore).
  Future<BillingResult> syncEntitlementFromStore() async {
    if (!isStoreAvailable) {
      return const BillingResult(success: false);
    }

    try {
      final info = await Purchases.getCustomerInfo();
      return _resultFromCustomerInfo(info);
    } catch (e, st) {
      if (_isInvalidCredentialsError(e)) {
        _available = false;
        _logBillingIssue('billing_sync', e, st);
        return BillingResult.storeUnavailable();
      }
      _logBillingIssue('billing_sync', e, st);
      return BillingResult.failure('Não foi possível verificar sua assinatura.');
    }
  }

  bool _isInvalidCredentialsError(Object error) {
    if (error is! PlatformException) return false;
    final code = error.code;
    final readable = error.details is Map
        ? (error.details as Map)['readable_error_code']?.toString()
        : null;
    return code == '11' ||
        readable == 'INVALID_CREDENTIALS' ||
        (error.message ?? '').contains('Invalid API Key');
  }

  void _logBillingIssue(String reason, Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      debugPrint('[BillingService] $reason: $error');
      return;
    }
    CrashReportingService.instance.recordError(error, stackTrace, reason: reason);
  }

  Future<BillingResult> purchasePlan(String planId) async {
    if (!isStoreAvailable) {
      return resolvePurchaseWhenStoreUnavailable(planId);
    }

    try {
      final offerings = await Purchases.getOfferings();
      final package = _packageForPlan(offerings, planId);
      if (package == null) {
        return BillingResult.failure('Plano indisponível no momento.');
      }

      AnalyticsService.instance.purchaseStarted(planId: planId);
      final customerInfo = await Purchases.purchasePackage(package);
      final billingResult = _resultFromCustomerInfo(customerInfo);

      if (billingResult.success) {
        AnalyticsService.instance.purchaseCompleted(planId: planId);
      }

      return billingResult;
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code == PurchasesErrorCode.purchaseCancelledError) {
        return BillingResult.failure('Compra cancelada.');
      }
      return BillingResult.failure('Erro na compra. Tente novamente.');
    } catch (e, st) {
      CrashReportingService.instance.recordError(e, st, reason: 'billing_purchase');
      return BillingResult.failure('Erro na compra. Tente novamente.');
    }
  }

  Future<BillingResult> restorePurchases() async {
    if (!isStoreAvailable) {
      return const BillingResult(success: false, errorMessage: 'Loja não configurada.');
    }

    try {
      final info = await Purchases.restorePurchases();
      final result = _resultFromCustomerInfo(info);
      if (!result.success) {
        return BillingResult.failure('Nenhuma compra encontrada para restaurar.');
      }
      return result;
    } catch (e, st) {
      CrashReportingService.instance.recordError(e, st, reason: 'billing_restore');
      return BillingResult.failure('Não foi possível restaurar compras.');
    }
  }

  BillingResult _resultFromCustomerInfo(CustomerInfo info) {
    final active = info.entitlements.active[BillingConfig.entitlementId];
    if (active == null) {
      return const BillingResult(success: false);
    }

    final planType = _planTypeFromProductId(active.productIdentifier);
    return BillingResult.granted(planType ?? ProPlanType.yearly);
  }

  Package? _packageForPlan(Offerings offerings, String planId) {
    final current = offerings.current;
    if (current == null) return null;

    for (final package in current.availablePackages) {
      if (package.storeProduct.identifier == planId) return package;
    }

    switch (planId) {
      case 'todoin_pro_monthly':
        return current.monthly;
      case 'todoin_pro_yearly':
        return current.annual;
      case 'todoin_pro_lifetime':
        return current.lifetime;
      default:
        return null;
    }
  }

  ProPlanType? _planTypeFromId(String id) {
    switch (id) {
      case 'todoin_pro_monthly':
        return ProPlanType.monthly;
      case 'todoin_pro_yearly':
        return ProPlanType.yearly;
      case 'todoin_pro_lifetime':
        return ProPlanType.lifetime;
      default:
        return null;
    }
  }

  /// Em debug sem loja, concede Pro localmente; em release, falha com segurança.
  @visibleForTesting
  BillingResult resolvePurchaseWhenStoreUnavailable(String planId) {
    if (kDebugMode) {
      return BillingResult.granted(
        _planTypeFromId(planId) ?? ProPlanType.yearly,
      );
    }
    return BillingResult.failure(
      'Loja de compras indisponível no momento.',
    );
  }

  ProPlanType? _planTypeFromProductId(String productId) {
    if (productId.contains('monthly')) return ProPlanType.monthly;
    if (productId.contains('yearly') || productId.contains('annual')) {
      return ProPlanType.yearly;
    }
    if (productId.contains('lifetime')) return ProPlanType.lifetime;
    return null;
  }
}
