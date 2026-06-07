import 'package:todoin_focus_app/features/reminders/domain/gateways/reminder_scheduler.dart';
import 'package:todoin_focus_app/features/reminders/presentation/providers/reminder_provider.dart';

class NoOpReminderScheduler implements ReminderScheduler {
  @override
  Future<void> cancelAll() async {}

  @override
  Future<void> schedule({
    required int hour,
    required int minute,
    required String message,
  }) async {}
}

final reminderTestOverrides = [
  reminderSchedulerProvider.overrideWithValue(NoOpReminderScheduler()),
];
