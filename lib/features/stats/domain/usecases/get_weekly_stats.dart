import '../../../../core/usecases/usecase.dart';
import '../entities/weekly_stats.dart';
import '../repositories/stats_repository.dart';

class GetWeeklyStats implements UseCase<WeeklyStats, NoParams> {
  final StatsRepository repository;

  GetWeeklyStats(this.repository);

  @override
  Future<WeeklyStats> call(NoParams params) => repository.getWeeklyStats();
}
