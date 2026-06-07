import '../../../../core/constants/free_tier_limits.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/entitlement.dart';

enum PaywallTrigger { taskLimit, afterCompletions, customTimer }

class ShouldShowPaywallParams {
  final Entitlement entitlement;
  final PaywallTrigger? explicitTrigger;

  const ShouldShowPaywallParams({
    required this.entitlement,
    this.explicitTrigger,
  });
}

class ShouldShowPaywall implements UseCase<bool, ShouldShowPaywallParams> {
  @override
  Future<bool> call(ShouldShowPaywallParams params) async {
    if (params.entitlement.isPro) return false;

    if (params.explicitTrigger != null) return true;

    if (params.entitlement.paywallDismissedAfterTrigger) return false;

    return params.entitlement.tasksCompletedCount >=
        FreeTierLimits.paywallAfterCompletions;
  }
}
