import '../../../../core/usecases/usecase.dart';
import '../gateways/billing_gateway.dart';
import '../repositories/entitlement_repository.dart';

class PurchasePlanParams {
  final String planId;

  const PurchasePlanParams({required this.planId});
}

class PurchasePlan implements UseCase<bool, PurchasePlanParams> {
  final EntitlementRepository repository;
  final BillingGateway billing;

  PurchasePlan(this.repository, this.billing);

  @override
  Future<bool> call(PurchasePlanParams params) async {
    final result = await billing.purchasePlan(params.planId);
    if (result.success && result.planType != null) {
      await repository.grantPro(result.planType!);
      return true;
    }
    return false;
  }
}
