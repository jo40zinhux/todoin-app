import 'package:flutter_test/flutter_test.dart';
import 'package:todoin_focus_app/features/backup/domain/entities/app_backup.dart';

void main() {
  test('round-trip JSON encoding', () {
    const backup = AppBackup(
      version: 1,
      exportedAt: '2026-06-07T10:00:00.000',
      tasks: [
        {'id': '1', 'title': 'Test', 'completed': false, 'subtasks': [], 'type': 'general'},
      ],
      xp: 10,
      stats: {'streak': {'currentStreak': 2}},
      settings: {'soundEnabled': true},
      reminders: {'enabled': false, 'hour': 9, 'minute': 0},
    );

    final restored = AppBackup.fromJson(backup.toJson());

    expect(restored.version, backup.version);
    expect(restored.xp, backup.xp);
    expect(restored.tasks.length, 1);
    expect(restored.tasks.first['title'], 'Test');
  });
}
