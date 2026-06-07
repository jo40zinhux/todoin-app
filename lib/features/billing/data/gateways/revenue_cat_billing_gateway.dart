import '../../../../core/services/billing_service.dart';
import '../../domain/entities/billing_result.dart';
import '../../domain/gateways/billing_gateway.dart';

/// Implementação da porta de billing via RevenueCat (singleton em core).
class RevenueCatBillingGateway implements BillingGateway {
  BillingService get _service => BillingService.instance;

  @override
  bool get isStoreAvailable => _service.isStoreAvailable;

  @override
  Future<void> initialize() => _service.initialize();

  @override
  Future<BillingResult> syncEntitlementFromStore() =>
      _service.syncEntitlementFromStore();

  @override
  Future<BillingResult> purchasePlan(String planId) =>
      _service.purchasePlan(planId);

  @override
  Future<BillingResult> restorePurchases() => _service.restorePurchases();
}
