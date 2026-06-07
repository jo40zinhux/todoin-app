import '../repositories/settings_repository.dart';

class ToggleHapticSetting {
  final SettingsRepository repository;

  ToggleHapticSetting(this.repository);

  Future<bool> call(bool currentValue) async {
    final newValue = !currentValue;
    await repository.saveHapticEnabled(newValue);
    return newValue;
  }
}
