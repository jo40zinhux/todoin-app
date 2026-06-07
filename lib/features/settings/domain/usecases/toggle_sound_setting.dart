import '../repositories/settings_repository.dart';

class ToggleSoundSetting {
  final SettingsRepository repository;

  ToggleSoundSetting(this.repository);

  Future<bool> call(bool currentValue) async {
    final newValue = !currentValue;
    await repository.saveSoundEnabled(newValue);
    return newValue;
  }
}
