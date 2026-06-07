import '../../../../core/services/notification_service.dart';
import '../../domain/gateways/reminder_scheduler.dart';

class NotificationReminderScheduler implements ReminderScheduler {
  @override
  Future<void> cancelAll() =>
      NotificationService.instance.cancelGentleReminders();

  @override
  Future<void> schedule({
    required int hour,
    required int minute,
    required String message,
  }) =>
      NotificationService.instance.scheduleGentleReminder(
        hour: hour,
        minute: minute,
        message: message,
      );
}
