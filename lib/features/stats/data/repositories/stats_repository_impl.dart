import '../../domain/entities/streak_state.dart';
import '../../domain/entities/weekly_stats.dart';
import '../../domain/repositories/stats_repository.dart';
import '../datasources/stats_local_datasource.dart';

class StatsRepositoryImpl implements StatsRepository {
  final StatsLocalDataSource dataSource;

  StatsRepositoryImpl(this.dataSource);

  @override
  Future<StreakState> getStreak() => dataSource.loadStreak();

  @override
  Future<WeeklyStats> getWeeklyStats() => dataSource.loadWeeklyStats();

  @override
  Future<void> recordTaskStarted() => dataSource.recordTaskStarted();

  @override
  Future<void> recordTaskCompleted({required int xpEarned}) =>
      dataSource.recordTaskCompleted(xpEarned: xpEarned);
}
