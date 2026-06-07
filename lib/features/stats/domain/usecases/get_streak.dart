import '../../../../core/usecases/usecase.dart';
import '../entities/streak_state.dart';
import '../repositories/stats_repository.dart';

class GetStreak implements UseCase<StreakState, NoParams> {
  final StatsRepository repository;

  GetStreak(this.repository);

  @override
  Future<StreakState> call(NoParams params) => repository.getStreak();
}
