import '../repositories/settings_repository.dart';

class ToggleBadDayMode {
  final SettingsRepository repository;

  ToggleBadDayMode(this.repository);

  Future<bool> call(bool currentValue) async {
    final newValue = !currentValue;
    await repository.saveBadDayMode(newValue);
    return newValue;
  }
}
