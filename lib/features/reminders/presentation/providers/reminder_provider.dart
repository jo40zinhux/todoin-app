import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/shared_preferences_provider.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/datasources/reminder_local_datasource.dart';
import '../../data/gateways/notification_reminder_scheduler.dart';
import '../../data/repositories/reminder_repository_impl.dart';
import '../../domain/gateways/reminder_scheduler.dart';
import '../../domain/entities/reminder_settings.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../../domain/usecases/reminder_usecases.dart';

final reminderDataSourceProvider = Provider<ReminderLocalDataSource>((ref) {
  return ReminderLocalDataSource(ref.watch(sharedPreferencesProvider));
});

final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  return ReminderRepositoryImpl(ref.watch(reminderDataSourceProvider));
});

final getReminderSettingsProvider = Provider<GetReminderSettings>((ref) {
  return GetReminderSettings(ref.watch(reminderRepositoryProvider));
});

final saveReminderSettingsProvider = Provider<SaveReminderSettings>((ref) {
  return SaveReminderSettings(ref.watch(reminderRepositoryProvider));
});

final reminderSchedulerProvider = Provider<ReminderScheduler>((ref) {
  return NotificationReminderScheduler();
});

final applyReminderScheduleProvider = Provider<ApplyReminderSchedule>((ref) {
  return ApplyReminderSchedule(ref.watch(reminderSchedulerProvider));
});

final reminderNotifierProvider =
    StateNotifierProvider<ReminderNotifier, ReminderSettings>((ref) {
  return ReminderNotifier(
    ref.watch(getReminderSettingsProvider),
    ref.watch(saveReminderSettingsProvider),
    ref.watch(applyReminderScheduleProvider),
  );
});

class ReminderNotifier extends StateNotifier<ReminderSettings> {
  final GetReminderSettings _getSettings;
  final SaveReminderSettings _saveSettings;
  final ApplyReminderSchedule _applySchedule;

  ReminderNotifier(
    this._getSettings,
    this._saveSettings,
    this._applySchedule,
  ) : super(const ReminderSettings()) {
    load();
  }

  Future<void> load() async {
    state = await _getSettings(NoParams());
    await _applySchedule(state);
  }

  Future<void> setEnabled(bool enabled) async {
    state = state.copyWith(enabled: enabled);
    await _saveSettings(state);
    await _applySchedule(state);
  }

  Future<void> setTime({required int hour, required int minute}) async {
    state = state.copyWith(hour: hour, minute: minute);
    await _saveSettings(state);
    if (state.enabled) await _applySchedule(state);
  }
}
