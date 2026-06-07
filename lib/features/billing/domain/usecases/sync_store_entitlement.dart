import '../../../../core/usecases/usecase.dart';
import '../gateways/billing_gateway.dart';
import '../repositories/entitlement_repository.dart';

/// Sincroniza Pro status com a loja no startup (RevenueCat).
class SyncStoreEntitlement implements UseCase<bool, NoParams> {
  final EntitlementRepository repository;
  final BillingGateway billing;

  SyncStoreEntitlement(this.repository, this.billing);

  @override
  Future<bool> call(NoParams params) async {
    if (!billing.isStoreAvailable) return false;

    final result = await billing.syncEntitlementFromStore();
    if (result.storeUnavailable) return false;

    if (result.success && result.planType != null) {
      await repository.grantPro(result.planType!);
      return true;
    }

    if (result.shouldRevokeLocalPro) {
      await repository.revokePro();
    }
    return false;
  }
}
