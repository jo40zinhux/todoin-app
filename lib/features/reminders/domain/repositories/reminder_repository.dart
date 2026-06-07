import '../entities/reminder_settings.dart';

abstract class ReminderRepository {
  Future<ReminderSettings> getSettings();
  Future<void> saveSettings(ReminderSettings settings);
}
