import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todoin_focus_app/features/reminders/domain/entities/reminder_settings.dart';
import 'package:todoin_focus_app/features/reminders/domain/gateways/reminder_scheduler.dart';
import 'package:todoin_focus_app/features/reminders/domain/usecases/reminder_usecases.dart';

class MockReminderScheduler extends Mock implements ReminderScheduler {}

void main() {
  late MockReminderScheduler scheduler;
  late ApplyReminderSchedule useCase;

  setUp(() {
    scheduler = MockReminderScheduler();
    useCase = ApplyReminderSchedule(scheduler);
  });

  test('cancels when disabled', () async {
    when(() => scheduler.cancelAll()).thenAnswer((_) async {});

    await useCase(const ReminderSettings(enabled: false));

    verify(() => scheduler.cancelAll()).called(1);
    verifyNever(() => scheduler.schedule(
          hour: any(named: 'hour'),
          minute: any(named: 'minute'),
          message: any(named: 'message'),
        ));
  });

  test('schedules when enabled', () async {
    when(
      () => scheduler.schedule(
        hour: any(named: 'hour'),
        minute: any(named: 'minute'),
        message: any(named: 'message'),
      ),
    ).thenAnswer((_) async {});

    await useCase(const ReminderSettings(enabled: true, hour: 9, minute: 30));

    verify(
      () => scheduler.schedule(hour: 9, minute: 30, message: any(named: 'message')),
    ).called(1);
    verifyNever(() => scheduler.cancelAll());
  });
}
