import 'package:shared_preferences/shared_preferences.dart';

abstract class SettingsLocalDataSource {
  Future<bool> getSoundEnabled();
  Future<bool> getHapticEnabled();
  Future<bool> getBadDayMode();
  Future<void> setSoundEnabled(bool value);
  Future<void> setHapticEnabled(bool value);
  Future<void> setBadDayMode(bool value);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  static const _soundKey = 'soundEnabled';
  static const _hapticKey = 'hapticEnabled';
  static const _badDayKey = 'badDayMode';

  final SharedPreferences sharedPreferences;

  SettingsLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<bool> getSoundEnabled() async {
    return sharedPreferences.getBool(_soundKey) ?? true;
  }

  @override
  Future<bool> getHapticEnabled() async {
    return sharedPreferences.getBool(_hapticKey) ?? true;
  }

  @override
  Future<void> setSoundEnabled(bool value) async {
    await sharedPreferences.setBool(_soundKey, value);
  }

  @override
  Future<void> setHapticEnabled(bool value) async {
    await sharedPreferences.setBool(_hapticKey, value);
  }

  @override
  Future<bool> getBadDayMode() async {
    return sharedPreferences.getBool(_badDayKey) ?? false;
  }

  @override
  Future<void> setBadDayMode(bool value) async {
    await sharedPreferences.setBool(_badDayKey, value);
  }
}
