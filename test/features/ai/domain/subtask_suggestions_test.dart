import 'package:flutter_test/flutter_test.dart';
import 'package:todoin_focus_app/features/ai/domain/subtask_suggestions.dart';
import 'package:todoin_focus_app/features/tasks/domain/entities/task.dart';

void main() {
  test('email tasks get email-specific subtasks', () {
    final result = suggestPersonalizedSubtasks(
      'Responder email do cliente',
      TaskType.general,
    );

    expect(result.first.title.toLowerCase(), contains('caixa'));
  });

  test('short titles get micro-step subtasks', () {
    final result = suggestPersonalizedSubtasks(
      'Lavar louça',
      TaskType.general,
    );

    expect(result.length, 3);
    expect(result.first.title, contains('Lavar louça'));
  });
}
