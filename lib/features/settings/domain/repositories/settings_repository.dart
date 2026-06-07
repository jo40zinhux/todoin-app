import '../entities/app_settings.dart';

abstract class SettingsRepository {
  Future<AppSettings> getSettings();
  Future<void> saveSoundEnabled(bool value);
  Future<void> saveHapticEnabled(bool value);
  Future<void> saveBadDayMode(bool value);
}
