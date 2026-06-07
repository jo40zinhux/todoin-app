import 'package:flutter_test/flutter_test.dart';
import 'package:todoin_focus_app/features/reminders/domain/reminder_messages.dart';

void main() {
  test('forDay returns deterministic message for same day', () {
    final date = DateTime(2026, 6, 7);
    expect(
      ReminderMessages.forDay(date),
      ReminderMessages.forDay(date),
    );
  });

  test('messages are non-empty and gentle tone', () {
    for (final message in ReminderMessages.messages) {
      expect(message.isNotEmpty, isTrue);
      expect(message.contains('culpa'), isFalse);
    }
  });
}
