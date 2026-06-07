import '../../../../core/constants/free_tier_limits.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/entitlement.dart';

class GetAvailableTimerDurations
    implements UseCase<List<int>, Entitlement> {
  @override
  Future<List<int>> call(Entitlement entitlement) async {
    if (entitlement.isPro) {
      return List<int>.from(ProTimerDurations.seconds);
    }
    return [FreeTierLimits.defaultTimerSeconds];
  }
}
