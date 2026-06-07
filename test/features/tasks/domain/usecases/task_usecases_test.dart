import 'package:flutter_test/flutter_test.dart';
import 'package:todoin_focus_app/features/tasks/domain/entities/subtask.dart';
import 'package:todoin_focus_app/features/tasks/domain/entities/task.dart';
import 'package:todoin_focus_app/features/tasks/domain/task_rules.dart';
import 'package:todoin_focus_app/features/tasks/domain/usecases/complete_task.dart';
import 'package:todoin_focus_app/features/tasks/domain/usecases/create_task.dart';
import 'package:todoin_focus_app/features/tasks/domain/usecases/remove_task.dart';
import 'package:todoin_focus_app/features/tasks/domain/usecases/toggle_subtask.dart';

void main() {
  group('CreateTask', () {
    final useCase = CreateTask();

    test('returns null for empty title', () {
      final result = useCase(const CreateTaskParams(title: '   ', type: TaskType.general));
      expect(result, isNull);
    });

    test('creates task with generated subtasks', () {
      final result = useCase(CreateTaskParams(
        title: 'Estudar Flutter',
        type: TaskType.study,
        id: 'test-id',
      ));

      expect(result, isNotNull);
      expect(result!.id, 'test-id');
      expect(result.title, 'Estudar Flutter');
      expect(result.subtasks.length, 3);
      expect(result.type, TaskType.study);
    });
  });

  group('ToggleSubtask', () {
    final useCase = ToggleSubtask();

    test('returns null for invalid index', () {
      const task = Task(id: '1', title: 'Task', subtasks: []);
      final result = useCase(ToggleSubtaskParams(task: task, subtaskIndex: 0));
      expect(result, isNull);
    });

    test('completes task and awards XP when last subtask is toggled', () {
      const task = Task(
        id: '1',
        title: 'Task',
        subtasks: [SubTask(title: 'step', done: false)],
      );

      final result = useCase(ToggleSubtaskParams(task: task, subtaskIndex: 0));

      expect(result, isNotNull);
      expect(result!.taskCompleted, isTrue);
      expect(result.xpEarned, kXpPerTaskCompletion);
      expect(result.updatedTask.completed, isTrue);
      expect(result.updatedTask.subtasks.first.done, isTrue);
    });
  });

  group('RemoveTask', () {
    final useCase = RemoveTask();

    test('returns removed false when task id is not found', () {
      const tasks = [Task(id: '1', title: 'Task', subtasks: [])];

      final result = useCase(RemoveTaskParams(tasks: tasks, taskId: 'missing'));

      expect(result.removed, isFalse);
      expect(result.updatedTasks, tasks);
    });

    test('removes task by id', () {
      const tasks = [
        Task(id: '1', title: 'Keep', subtasks: []),
        Task(id: '2', title: 'Remove', subtasks: []),
      ];

      final result = useCase(RemoveTaskParams(tasks: tasks, taskId: '2'));

      expect(result.removed, isTrue);
      expect(result.updatedTasks.length, 1);
      expect(result.updatedTasks.first.id, '1');
    });
  });

  group('CompleteTask', () {
    final useCase = CompleteTask();

    test('returns null when task is already completed', () {
      const task = Task(
        id: '1',
        title: 'Task',
        completed: true,
        subtasks: [SubTask(title: 'step', done: true)],
      );

      final result = useCase(CompleteTaskParams(task: task));
      expect(result, isNull);
    });

    test('marks all subtasks done and awards XP', () {
      const task = Task(
        id: '1',
        title: 'Task',
        subtasks: [
          SubTask(title: 'a', done: false),
          SubTask(title: 'b', done: true),
        ],
      );

      final result = useCase(CompleteTaskParams(task: task));

      expect(result, isNotNull);
      expect(result!.xpEarned, kXpPerTaskCompletion);
      expect(result.updatedTask.completed, isTrue);
      expect(result.updatedTask.subtasks.every((s) => s.done), isTrue);
    });
  });
}
