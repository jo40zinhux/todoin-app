import '../../../../core/usecases/usecase.dart';
import '../entities/reminder_settings.dart';
import '../gateways/reminder_scheduler.dart';
import '../reminder_messages.dart';
import '../repositories/reminder_repository.dart';

class GetReminderSettings implements UseCase<ReminderSettings, NoParams> {
  final ReminderRepository repository;

  GetReminderSettings(this.repository);

  @override
  Future<ReminderSettings> call(NoParams params) => repository.getSettings();
}

class SaveReminderSettings implements UseCase<void, ReminderSettings> {
  final ReminderRepository repository;

  SaveReminderSettings(this.repository);

  @override
  Future<void> call(ReminderSettings params) => repository.saveSettings(params);
}

class ApplyReminderSchedule implements UseCase<void, ReminderSettings> {
  final ReminderScheduler scheduler;

  ApplyReminderSchedule(this.scheduler);

  @override
  Future<void> call(ReminderSettings settings) async {
    if (!settings.enabled) {
      await scheduler.cancelAll();
      return;
    }

    final message = ReminderMessages.forDay(DateTime.now());
    await scheduler.schedule(
      hour: settings.hour,
      minute: settings.minute,
      message: message,
    );
  }
}
