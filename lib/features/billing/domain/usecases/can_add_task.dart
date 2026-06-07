import '../../../../core/constants/free_tier_limits.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../tasks/domain/entities/task.dart';
import '../entities/entitlement.dart';

class CanAddTaskParams {
  final List<Task> tasks;
  final Entitlement entitlement;

  const CanAddTaskParams({required this.tasks, required this.entitlement});
}

class CanAddTask implements UseCase<bool, CanAddTaskParams> {
  @override
  Future<bool> call(CanAddTaskParams params) async {
    if (params.entitlement.isPro) return true;
    final active =
        params.tasks.where((t) => !t.completed).length;
    return active < FreeTierLimits.maxActiveTasks;
  }
}
