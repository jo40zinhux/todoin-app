import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;

  SettingsRepositoryImpl({required this.localDataSource});

  @override
  Future<AppSettings> getSettings() async {
    final soundEnabled = await localDataSource.getSoundEnabled();
    final hapticEnabled = await localDataSource.getHapticEnabled();
    final badDayMode = await localDataSource.getBadDayMode();
    return AppSettings(
      soundEnabled: soundEnabled,
      hapticEnabled: hapticEnabled,
      badDayMode: badDayMode,
    );
  }

  @override
  Future<void> saveSoundEnabled(bool value) async {
    await localDataSource.setSoundEnabled(value);
  }

  @override
  Future<void> saveHapticEnabled(bool value) async {
    await localDataSource.setHapticEnabled(value);
  }

  @override
  Future<void> saveBadDayMode(bool value) async {
    await localDataSource.setBadDayMode(value);
  }
}
