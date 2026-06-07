import 'package:flutter_test/flutter_test.dart';
import 'package:todoin_focus_app/core/validation/input_limits.dart';
import 'package:todoin_focus_app/features/tasks/domain/entities/task.dart';
import 'package:todoin_focus_app/features/tasks/domain/usecases/create_task.dart';

void main() {
  late CreateTask createTask;

  setUp(() {
    createTask = CreateTask();
  });

  test('returns null for empty title', () {
    final result = createTask(
      const CreateTaskParams(title: '   ', type: TaskType.general),
    );
    expect(result, isNull);
  });

  test('returns null when title exceeds max length', () {
    final longTitle = 'a' * (InputLimits.maxTaskTitleLength + 1);
    final result = createTask(
      CreateTaskParams(title: longTitle, type: TaskType.general),
    );
    expect(result, isNull);
  });

  test('creates task with valid title', () {
    final result = createTask(
      const CreateTaskParams(title: 'Estudar Flutter', type: TaskType.study),
    );
    expect(result, isNotNull);
    expect(result!.title, 'Estudar Flutter');
    expect(result.subtasks, isNotEmpty);
  });

  test('trims whitespace from title', () {
    final result = createTask(
      const CreateTaskParams(title: '  Focar  ', type: TaskType.general),
    );
    expect(result?.title, 'Focar');
  });
}
