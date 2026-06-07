import '../../../../core/usecases/usecase.dart';
import '../gateways/billing_gateway.dart';
import '../repositories/entitlement_repository.dart';

class RestorePurchases implements UseCase<bool, NoParams> {
  final EntitlementRepository repository;
  final BillingGateway billing;

  RestorePurchases(this.repository, this.billing);

  @override
  Future<bool> call(NoParams params) async {
    final result = await billing.restorePurchases();

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
