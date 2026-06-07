import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/shared_preferences_provider.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/datasources/stats_local_datasource.dart';
import '../../data/repositories/stats_repository_impl.dart';
import '../../domain/entities/streak_state.dart';
import '../../domain/entities/weekly_stats.dart';
import '../../domain/repositories/stats_repository.dart';
import '../../domain/usecases/get_streak.dart';
import '../../domain/usecases/get_weekly_stats.dart';
import '../../domain/usecases/record_task_activity.dart';

final statsDataSourceProvider = Provider<StatsLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return StatsLocalDataSource(prefs);
});

final statsRepositoryProvider = Provider<StatsRepository>((ref) {
  return StatsRepositoryImpl(ref.watch(statsDataSourceProvider));
});

final getStreakProvider = Provider<GetStreak>((ref) {
  return GetStreak(ref.watch(statsRepositoryProvider));
});

final getWeeklyStatsProvider = Provider<GetWeeklyStats>((ref) {
  return GetWeeklyStats(ref.watch(statsRepositoryProvider));
});

final recordTaskStartedProvider = Provider<RecordTaskStarted>((ref) {
  return RecordTaskStarted(ref.watch(statsRepositoryProvider));
});

final recordTaskCompletedProvider = Provider<RecordTaskCompleted>((ref) {
  return RecordTaskCompleted(ref.watch(statsRepositoryProvider));
});

class StatsSnapshot {
  final StreakState streak;
  final WeeklyStats weekly;

  const StatsSnapshot({required this.streak, required this.weekly});
}

final statsNotifierProvider =
    StateNotifierProvider<StatsNotifier, AsyncValue<StatsSnapshot>>((ref) {
  return StatsNotifier(
    ref.watch(getStreakProvider),
    ref.watch(getWeeklyStatsProvider),
    ref.watch(recordTaskStartedProvider),
    ref.watch(recordTaskCompletedProvider),
  );
});

class StatsNotifier extends StateNotifier<AsyncValue<StatsSnapshot>> {
  final GetStreak _getStreak;
  final GetWeeklyStats _getWeeklyStats;
  final RecordTaskStarted _recordStarted;
  final RecordTaskCompleted _recordCompleted;

  StatsNotifier(
    this._getStreak,
    this._getWeeklyStats,
    this._recordStarted,
    this._recordCompleted,
  ) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    try {
      final streak = await _getStreak(NoParams());
      final weekly = await _getWeeklyStats(NoParams());
      state = AsyncValue.data(StatsSnapshot(streak: streak, weekly: weekly));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> onTaskStarted() async {
    await _recordStarted(NoParams());
    await load();
  }

  Future<void> onTaskCompleted({required int xpEarned}) async {
    await _recordCompleted(RecordTaskCompletedParams(xpEarned: xpEarned));
    await load();
  }
}
