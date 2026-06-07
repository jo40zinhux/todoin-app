import '../../domain/entities/reminder_settings.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../datasources/reminder_local_datasource.dart';

class ReminderRepositoryImpl implements ReminderRepository {
  final ReminderLocalDataSource dataSource;

  ReminderRepositoryImpl(this.dataSource);

  @override
  Future<ReminderSettings> getSettings() => dataSource.load();

  @override
  Future<void> saveSettings(ReminderSettings settings) =>
      dataSource.save(settings);
}
