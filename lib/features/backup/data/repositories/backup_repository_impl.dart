import 'dart:convert';

import '../../../reminders/data/datasources/reminder_local_datasource.dart';
import '../../../settings/data/datasources/settings_local_datasource.dart';
import '../../../stats/data/datasources/stats_local_datasource.dart';
import '../../../tasks/data/datasources/task_local_datasource.dart';
import '../../../tasks/data/models/task_model.dart';
import '../../domain/entities/app_backup.dart';
import '../../domain/repositories/backup_repository.dart';

class BackupRepositoryImpl implements BackupRepository {
  static const _backupVersion = 1;

  final TaskLocalDataSource taskDataSource;
  final SettingsLocalDataSource settingsDataSource;
  final StatsLocalDataSource statsDataSource;
  final ReminderLocalDataSource reminderDataSource;

  BackupRepositoryImpl({
    required this.taskDataSource,
    required this.settingsDataSource,
    required this.statsDataSource,
    required this.reminderDataSource,
  });

  @override
  Future<AppBackup> createBackup() async {
    final tasksResult = await taskDataSource.getTasks();
    final xp = await taskDataSource.getXp();
    final streak = await statsDataSource.loadStreak();
    final weekly = await statsDataSource.loadWeeklyStats();

    return AppBackup(
      version: _backupVersion,
      exportedAt: DateTime.now().toIso8601String(),
      tasks: tasksResult.tasks.map((t) => t.toJson()).toList(),
      xp: xp,
      stats: {
        'streak': {
          'currentStreak': streak.currentStreak,
          'longestStreak': streak.longestStreak,
          'lastActiveDate': streak.lastActiveDate?.toIso8601String(),
        },
        'weekly': {
          'tasksCompleted': weekly.tasksCompleted,
          'tasksStarted': weekly.tasksStarted,
          'xpEarned': weekly.xpEarned,
        },
      },
      settings: {
        'soundEnabled': await settingsDataSource.getSoundEnabled(),
        'hapticEnabled': await settingsDataSource.getHapticEnabled(),
        'badDayMode': await settingsDataSource.getBadDayMode(),
      },
      reminders: {
        'enabled': (await reminderDataSource.load()).enabled,
        'hour': (await reminderDataSource.load()).hour,
        'minute': (await reminderDataSource.load()).minute,
      },
    );
  }

  @override
  Future<void> restoreBackup(AppBackup backup) async {
    if (backup.version > _backupVersion) {
      throw const FormatException('Backup de versão não suportada.');
    }

    final taskModels = backup.tasks.map(TaskModel.fromJson).toList();
    await taskDataSource.saveTasks(taskModels);
    await taskDataSource.saveXp(backup.xp);

    final streakMap = backup.stats['streak'] as Map<String, dynamic>?;
    if (streakMap != null) {
      await statsDataSource.restoreStreak(
        currentStreak: streakMap['currentStreak'] as int? ?? 0,
        longestStreak: streakMap['longestStreak'] as int? ?? 0,
        lastActiveDate: streakMap['lastActiveDate'] != null
            ? DateTime.parse(streakMap['lastActiveDate'] as String)
            : null,
      );
    }

    final weeklyMap = backup.stats['weekly'] as Map<String, dynamic>?;
    if (weeklyMap != null) {
      await statsDataSource.restoreWeekly(
        tasksCompleted: weeklyMap['tasksCompleted'] as int? ?? 0,
        tasksStarted: weeklyMap['tasksStarted'] as int? ?? 0,
        xpEarned: weeklyMap['xpEarned'] as int? ?? 0,
      );
    }

    final settings = backup.settings;
    if (settings.isNotEmpty) {
      await settingsDataSource.setSoundEnabled(
        settings['soundEnabled'] as bool? ?? true,
      );
      await settingsDataSource.setHapticEnabled(
        settings['hapticEnabled'] as bool? ?? true,
      );
      await settingsDataSource.setBadDayMode(
        settings['badDayMode'] as bool? ?? false,
      );
    }

    final reminders = backup.reminders;
    if (reminders.isNotEmpty) {
      final current = await reminderDataSource.load();
      await reminderDataSource.save(
        current.copyWith(
          enabled: reminders['enabled'] as bool? ?? false,
          hour: reminders['hour'] as int? ?? 9,
          minute: reminders['minute'] as int? ?? 0,
        ),
      );
    }
  }

  String encode(AppBackup backup) =>
      const JsonEncoder.withIndent('  ').convert(backup.toJson());

  AppBackup decode(String raw) {
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return AppBackup.fromJson(map);
  }
}
