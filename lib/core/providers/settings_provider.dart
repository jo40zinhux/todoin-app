import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/feedback_service.dart';
import '../../features/tasks/presentation/providers/tasks_provider.dart';

class SettingsState {
  final bool soundEnabled;
  final bool hapticEnabled;

  SettingsState({
    this.soundEnabled = true,
    this.hapticEnabled = true,
  });

  SettingsState copyWith({
    bool? soundEnabled,
    bool? hapticEnabled,
  }) {
    return SettingsState(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final SharedPreferences _prefs;

  SettingsNotifier(this._prefs) : super(SettingsState()) {
    _loadSettings();
  }

  void _loadSettings() {
    final soundEnabled = _prefs.getBool('soundEnabled') ?? true;
    final hapticEnabled = _prefs.getBool('hapticEnabled') ?? true;
    
    // Update service directly to keep it in sync
    FeedbackService.soundEnabled = soundEnabled;
    FeedbackService.hapticEnabled = hapticEnabled;
    
    state = SettingsState(
      soundEnabled: soundEnabled,
      hapticEnabled: hapticEnabled,
    );
  }

  Future<void> toggleSound() async {
    final newValue = !state.soundEnabled;
    await _prefs.setBool('soundEnabled', newValue);
    FeedbackService.soundEnabled = newValue;
    state = state.copyWith(soundEnabled: newValue);
  }

  Future<void> toggleHaptic() async {
    final newValue = !state.hapticEnabled;
    await _prefs.setBool('hapticEnabled', newValue);
    FeedbackService.hapticEnabled = newValue;
    state = state.copyWith(hapticEnabled: newValue);
  }
}

final settingsNotifierProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsNotifier(prefs);
});
