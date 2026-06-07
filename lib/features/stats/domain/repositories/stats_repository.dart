import '../entities/streak_state.dart';
import '../entities/weekly_stats.dart';

abstract class StatsRepository {
  Future<StreakState> getStreak();
  Future<WeeklyStats> getWeeklyStats();
  Future<void> recordTaskStarted();
  Future<void> recordTaskCompleted({required int xpEarned});
}
