import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoin_focus_app/features/backup/data/repositories/backup_repository_impl.dart';
import 'package:todoin_focus_app/features/backup/domain/entities/app_backup.dart';
import 'package:todoin_focus_app/features/reminders/data/datasources/reminder_local_datasource.dart';
import 'package:todoin_focus_app/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:todoin_focus_app/features/stats/data/datasources/stats_local_datasource.dart';
import 'package:todoin_focus_app/features/tasks/data/datasources/task_local_datasource.dart';
import 'package:todoin_focus_app/features/tasks/data/models/task_model.dart';

void main() {
  late BackupRepositoryImpl repository;
  late TaskLocalDataSource taskDataSource;
  late SettingsLocalDataSource settingsDataSource;
  late StatsLocalDataSource statsDataSource;
  late ReminderLocalDataSource reminderDataSource;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    taskDataSource = TaskLocalDataSourceImpl(sharedPreferences: prefs);
    settingsDataSource = SettingsLocalDataSourceImpl(sharedPreferences: prefs);
    statsDataSource = StatsLocalDataSource(prefs);
    reminderDataSource = ReminderLocalDataSource(prefs);
    repository = BackupRepositoryImpl(
      taskDataSource: taskDataSource,
      settingsDataSource: settingsDataSource,
      statsDataSource: statsDataSource,
      reminderDataSource: reminderDataSource,
    );
  });

  test('createBackup captures local state', () async {
    await taskDataSource.saveTasks([
      const TaskModel(id: '1', title: 'Estudar', subtasks: []),
    ]);
    await taskDataSource.saveXp(15);
    await settingsDataSource.setBadDayMode(true);

    final backup = await repository.createBackup();

    expect(backup.tasks.length, 1);
    expect(backup.tasks.first['title'], 'Estudar');
    expect(backup.xp, 15);
    expect(backup.settings['badDayMode'], isTrue);
  });

  test('restoreBackup writes tasks, xp, settings and reminders', () async {
    const backup = AppBackup(
      version: 1,
      exportedAt: '2026-06-08T12:00:00.000',
      tasks: [
        {
          'id': '2',
          'title': 'Backup task',
          'completed': false,
          'subtasks': [],
          'type': 'general',
        },
      ],
      xp: 42,
      stats: {
        'streak': {'currentStreak': 3, 'longestStreak': 5},
        'weekly': {'tasksCompleted': 2, 'tasksStarted': 4, 'xpEarned': 20},
      },
      settings: {
        'soundEnabled': false,
        'hapticEnabled': true,
        'badDayMode': true,
      },
      reminders: {'enabled': true, 'hour': 10, 'minute': 30},
    );

    await repository.restoreBackup(backup);

    final tasks = await taskDataSource.getTasks();
    expect(tasks.tasks.first.title, 'Backup task');
    expect(await taskDataSource.getXp(), 42);
    expect(await settingsDataSource.getSoundEnabled(), isFalse);
    expect(await settingsDataSource.getBadDayMode(), isTrue);

    final streak = await statsDataSource.loadStreak();
    expect(streak.currentStreak, 3);
    expect(streak.longestStreak, 5);

    final reminders = await reminderDataSource.load();
    expect(reminders.enabled, isTrue);
    expect(reminders.hour, 10);
    expect(reminders.minute, 30);
  });

  test('restoreBackup rejects unsupported version', () async {
    const backup = AppBackup(
      version: 99,
      exportedAt: '2026-06-08T12:00:00.000',
      tasks: [],
      xp: 0,
      stats: {},
      settings: {},
      reminders: {},
    );

    expect(
      () => repository.restoreBackup(backup),
      throwsA(isA<FormatException>()),
    );
  });
}
