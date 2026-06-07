import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/shared_preferences_provider.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../reminders/data/datasources/reminder_local_datasource.dart';
import '../../../settings/data/datasources/settings_local_datasource.dart';
import '../../../stats/data/datasources/stats_local_datasource.dart';
import '../../../tasks/data/datasources/task_local_datasource.dart';
import '../../data/repositories/backup_repository_impl.dart';
import '../../domain/repositories/backup_repository.dart';
import '../../domain/usecases/export_backup.dart';
import '../../domain/usecases/import_backup.dart';

final backupRepositoryProvider = Provider<BackupRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return BackupRepositoryImpl(
    taskDataSource: TaskLocalDataSourceImpl(sharedPreferences: prefs),
    settingsDataSource: SettingsLocalDataSourceImpl(sharedPreferences: prefs),
    statsDataSource: StatsLocalDataSource(prefs),
    reminderDataSource: ReminderLocalDataSource(prefs),
  );
});

final exportBackupProvider = Provider<ExportBackup>((ref) {
  return ExportBackup(ref.watch(backupRepositoryProvider));
});

final importBackupProvider = Provider<ImportBackup>((ref) {
  return ImportBackup(ref.watch(backupRepositoryProvider));
});
