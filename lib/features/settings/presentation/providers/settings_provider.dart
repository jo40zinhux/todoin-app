import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/shared_preferences_provider.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/services/feedback_service.dart';
import '../../data/datasources/settings_local_datasource.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/usecases/get_settings.dart';
import '../../domain/usecases/toggle_bad_day_mode.dart';
import '../../domain/usecases/toggle_haptic_setting.dart';
import '../../domain/usecases/toggle_sound_setting.dart';

final settingsLocalDataSourceProvider = Provider<SettingsLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsLocalDataSourceImpl(sharedPreferences: prefs);
});

final settingsRepositoryProvider = Provider<SettingsRepositoryImpl>((ref) {
  return SettingsRepositoryImpl(
    localDataSource: ref.watch(settingsLocalDataSourceProvider),
  );
});

final getSettingsProvider = Provider<GetSettings>((ref) {
  return GetSettings(ref.watch(settingsRepositoryProvider));
});

final toggleSoundSettingProvider = Provider<ToggleSoundSetting>((ref) {
  return ToggleSoundSetting(ref.watch(settingsRepositoryProvider));
});

final toggleHapticSettingProvider = Provider<ToggleHapticSetting>((ref) {
  return ToggleHapticSetting(ref.watch(settingsRepositoryProvider));
});

final toggleBadDayModeProvider = Provider<ToggleBadDayMode>((ref) {
  return ToggleBadDayMode(ref.watch(settingsRepositoryProvider));
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  final GetSettings _getSettings;
  final ToggleSoundSetting _toggleSound;
  final ToggleHapticSetting _toggleHaptic;
  final ToggleBadDayMode _toggleBadDay;

  SettingsNotifier(
    super.initialState,
    this._getSettings,
    this._toggleSound,
    this._toggleHaptic,
    this._toggleBadDay,
  );

  Future<void> load() async {
    final settings = await _getSettings(NoParams());
    _applyToFeedbackService(settings);
    state = settings;
  }

  void _applyToFeedbackService(AppSettings settings) {
    FeedbackService.soundEnabled = settings.soundEnabled;
    FeedbackService.hapticEnabled = settings.hapticEnabled;
  }

  Future<void> toggleSound() async {
    final newValue = await _toggleSound(state.soundEnabled);
    FeedbackService.soundEnabled = newValue;
    state = state.copyWith(soundEnabled: newValue);
  }

  Future<void> toggleHaptic() async {
    final newValue = await _toggleHaptic(state.hapticEnabled);
    FeedbackService.hapticEnabled = newValue;
    state = state.copyWith(hapticEnabled: newValue);
  }

  Future<void> toggleBadDayMode() async {
    final newValue = await _toggleBadDay(state.badDayMode);
    state = state.copyWith(badDayMode: newValue);
  }
}

final settingsNotifierProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  final notifier = SettingsNotifier(
    const AppSettings(),
    ref.watch(getSettingsProvider),
    ref.watch(toggleSoundSettingProvider),
    ref.watch(toggleHapticSettingProvider),
    ref.watch(toggleBadDayModeProvider),
  );
  notifier.load();
  return notifier;
});
