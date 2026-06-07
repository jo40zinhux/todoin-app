import '../entities/billing_result.dart';

/// Porta de domínio para operações de billing (RevenueCat / loja).
abstract class BillingGateway {
  bool get isStoreAvailable;

  Future<void> initialize();

  Future<BillingResult> syncEntitlementFromStore();

  Future<BillingResult> purchasePlan(String planId);

  Future<BillingResult> restorePurchases();
}
