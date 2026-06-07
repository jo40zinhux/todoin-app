import 'package:flutter_test/flutter_test.dart';
import 'package:todoin_focus_app/features/settings/domain/entities/app_settings.dart';
import 'package:todoin_focus_app/features/tasks/domain/entities/subtask.dart';
import 'package:todoin_focus_app/features/tasks/domain/entities/task.dart';

void main() {
  group('Task equality', () {
    const taskA = Task(
      id: '1',
      title: 'Study',
      subtasks: [SubTask(title: 'step', done: false)],
      type: TaskType.study,
    );

    const taskB = Task(
      id: '1',
      title: 'Study',
      subtasks: [SubTask(title: 'step', done: false)],
      type: TaskType.study,
    );

    const taskC = Task(
      id: '2',
      title: 'Other',
      subtasks: [],
    );

    test('equal tasks compare as equal', () {
      expect(taskA, equals(taskB));
    });

    test('different tasks compare as not equal', () {
      expect(taskA, isNot(equals(taskC)));
    });
  });

  group('AppSettings equality', () {
    test('equal settings compare as equal', () {
      const a = AppSettings(soundEnabled: true, hapticEnabled: false);
      const b = AppSettings(soundEnabled: true, hapticEnabled: false);

      expect(a, equals(b));
    });

    test('different settings compare as not equal', () {
      const a = AppSettings(soundEnabled: true, hapticEnabled: false);
      const b = AppSettings(soundEnabled: false, hapticEnabled: false);

      expect(a, isNot(equals(b)));
    });
  });
}
