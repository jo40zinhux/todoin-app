import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/streak_state.dart';
import '../../domain/entities/weekly_stats.dart';
import '../../domain/streak_rules.dart';

class StatsLocalDataSource {
  static const _streakKey = 'stats_streak';
  static const _weeklyKey = 'stats_weekly';
  static const _weekStartKey = 'stats_week_start';

  final SharedPreferences prefs;

  StatsLocalDataSource(this.prefs);

  Future<StreakState> loadStreak() async {
    final raw = prefs.getString(_streakKey);
    if (raw == null) return const StreakState();

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return StreakState(
        currentStreak: map['currentStreak'] as int? ?? 0,
        longestStreak: map['longestStreak'] as int? ?? 0,
        lastActiveDate: map['lastActiveDate'] != null
            ? DateTime.parse(map['lastActiveDate'] as String)
            : null,
      );
    } catch (e) {
      debugPrint('[StatsLocalDataSource] Streak JSON corrompido: $e');
      await prefs.remove(_streakKey);
      return const StreakState();
    }
  }

  Future<void> saveStreak(StreakState streak) async {
    final map = {
      'currentStreak': streak.currentStreak,
      'longestStreak': streak.longestStreak,
      'lastActiveDate': streak.lastActiveDate?.toIso8601String(),
    };
    await prefs.setString(_streakKey, jsonEncode(map));
  }

  DateTime _weekStart(DateTime now) {
    final weekday = now.weekday;
    final monday = now.subtract(Duration(days: weekday - 1));
    return DateTime(monday.year, monday.month, monday.day);
  }

  Future<WeeklyStats> loadWeeklyStats() async {
    final weekStart = _weekStart(DateTime.now());
    final storedStart = prefs.getString(_weekStartKey);

    if (storedStart == null || storedStart != weekStart.toIso8601String()) {
      return const WeeklyStats();
    }

    final raw = prefs.getString(_weeklyKey);
    if (raw == null) return const WeeklyStats();

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return WeeklyStats(
        tasksCompleted: map['tasksCompleted'] as int? ?? 0,
        tasksStarted: map['tasksStarted'] as int? ?? 0,
        xpEarned: map['xpEarned'] as int? ?? 0,
      );
    } catch (e) {
      debugPrint('[StatsLocalDataSource] Weekly JSON corrompido: $e');
      await prefs.remove(_weeklyKey);
      await prefs.remove(_weekStartKey);
      return const WeeklyStats();
    }
  }

  Future<void> _saveWeekly(WeeklyStats stats, DateTime weekStart) async {
    await prefs.setString(_weekStartKey, weekStart.toIso8601String());
    await prefs.setString(
      _weeklyKey,
      jsonEncode({
        'tasksCompleted': stats.tasksCompleted,
        'tasksStarted': stats.tasksStarted,
        'xpEarned': stats.xpEarned,
      }),
    );
  }

  Future<void> recordTaskStarted() async {
    final weekStart = _weekStart(DateTime.now());
    final current = await loadWeeklyStats();
    await _saveWeekly(
      WeeklyStats(
        tasksCompleted: current.tasksCompleted,
        tasksStarted: current.tasksStarted + 1,
        xpEarned: current.xpEarned,
      ),
      weekStart,
    );
  }

  Future<void> restoreStreak({
    required int currentStreak,
    required int longestStreak,
    DateTime? lastActiveDate,
  }) async {
    await saveStreak(
      StreakState(
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        lastActiveDate: lastActiveDate,
      ),
    );
  }

  Future<void> restoreWeekly({
    required int tasksCompleted,
    required int tasksStarted,
    required int xpEarned,
  }) async {
    final weekStart = _weekStart(DateTime.now());
    await _saveWeekly(
      WeeklyStats(
        tasksCompleted: tasksCompleted,
        tasksStarted: tasksStarted,
        xpEarned: xpEarned,
      ),
      weekStart,
    );
  }

  Future<void> recordTaskCompleted({required int xpEarned}) async {
    final weekStart = _weekStart(DateTime.now());
    final streak = await loadStreak();
    final updatedStreak = updateGentleStreak(streak, DateTime.now());
    await saveStreak(updatedStreak);

    final current = await loadWeeklyStats();
    await _saveWeekly(
      WeeklyStats(
        tasksCompleted: current.tasksCompleted + 1,
        tasksStarted: current.tasksStarted,
        xpEarned: current.xpEarned + xpEarned,
      ),
      weekStart,
    );
  }
}
