import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todoin_focus_app/features/billing/domain/entities/entitlement.dart';
import 'package:todoin_focus_app/features/billing/domain/usecases/can_add_task.dart';
import 'package:todoin_focus_app/features/tasks/domain/add_task_result.dart';
import 'package:todoin_focus_app/features/tasks/domain/entities/task.dart';
import 'package:todoin_focus_app/features/tasks/domain/entities/subtask.dart';
import 'package:todoin_focus_app/features/tasks/domain/usecases/complete_task.dart';
import 'package:todoin_focus_app/features/tasks/domain/usecases/create_task.dart';
import 'package:todoin_focus_app/features/tasks/domain/usecases/save_tasks.dart';
import 'package:todoin_focus_app/features/tasks/domain/usecases/save_xp.dart';
import 'package:todoin_focus_app/features/tasks/domain/usecases/remove_task.dart';
import 'package:todoin_focus_app/features/tasks/domain/usecases/toggle_subtask.dart';
import 'package:todoin_focus_app/features/tasks/presentation/providers/tasks_provider.dart';

class MockSaveTasks extends Mock implements SaveTasks {}

class MockSaveXp extends Mock implements SaveXp {}

void main() {
  late MockSaveTasks mockSaveTasks;
  late MockSaveXp mockSaveXp;
  late CreateTask createTask;
  late ToggleSubtask toggleSubtask;
  late CompleteTask completeTask;
  late RemoveTask removeTask;

  setUp(() {
    mockSaveTasks = MockSaveTasks();
    mockSaveXp = MockSaveXp();
    createTask = CreateTask();
    toggleSubtask = ToggleSubtask();
    completeTask = CompleteTask();
    removeTask = RemoveTask();

    registerFallbackValue(const <Task>[]);
  });

  TasksNotifier buildNotifier({
    XpEarnedCallback? onXpEarned,
    TaskCompletedCallback? onTaskCompleted,
    Future<Entitlement> Function()? getEntitlement,
  }) {
    return TasksNotifier(
      [],
      mockSaveTasks,
      createTask,
      toggleSubtask,
      completeTask,
      removeTask,
      CanAddTask(),
      getEntitlement ?? () async => const Entitlement(isPro: true),
      onXpEarned ?? (amount) => mockSaveXp(amount),
      onTaskCompleted ?? (_) async {},
    );
  }

  group('XpNotifier Tests', () {
    test('should add XP and call saveXp', () async {
      when(() => mockSaveXp(any())).thenAnswer((_) async => {});
      final notifier = XpNotifier(0, mockSaveXp);

      await notifier.addXp(10);

      expect(notifier.state, 10);
      verify(() => mockSaveXp(10)).called(1);
    });

    test('should set custom XP directly', () {
      final notifier = XpNotifier(0, mockSaveXp);

      notifier.setXp(50);

      expect(notifier.state, 50);
      verifyNever(() => mockSaveXp(any()));
    });
  });

  group('TasksNotifier Tests', () {
    late TasksNotifier notifier;

    setUp(() {
      when(() => mockSaveTasks(any())).thenAnswer((_) async => {});
      when(() => mockSaveXp(any())).thenAnswer((_) async => {});
      notifier = buildNotifier(onXpEarned: (amount) async {
        await mockSaveXp(amount);
      });
    });

    test('should add new task', () async {
      final result = await notifier.addTask('Test Task', TaskType.general);

      expect(result, AddTaskResult.success);
      expect(notifier.state.length, 1);
      expect(notifier.state.first.title, 'Test Task');
      expect(notifier.state.first.subtasks.length, 3);
      verify(() => mockSaveTasks(any(that: isA<List<Task>>()))).called(1);
    });

    test('should remove task', () async {
      const task = Task(id: '1', title: 'Task 1', subtasks: []);
      notifier.setAll([task]);

      final removed = await notifier.removeTask('1');

      expect(removed, isTrue);
      expect(notifier.state, isEmpty);
      verify(() => mockSaveTasks(any(that: isEmpty))).called(1);
    });

    test('removeTask returns false when task id does not exist', () async {
      const task = Task(id: '1', title: 'Task 1', subtasks: []);
      notifier.setAll([task]);

      final removed = await notifier.removeTask('missing');

      expect(removed, isFalse);
      expect(notifier.state.length, 1);
      verifyNever(() => mockSaveTasks(any()));
    });

    test('should complete all subtasks and complete main task, issuing XP',
        () async {
      const task = Task(
        id: '1',
        title: 'Task 1',
        subtasks: [SubTask(title: 'sub', done: false)],
      );
      notifier.setAll([task]);

      final completed = await notifier.toggleSubtask('1', 0);

      expect(completed, isTrue);
      expect(notifier.state.first.completed, isTrue);
      expect(notifier.state.first.subtasks.first.done, isTrue);
      verify(() => mockSaveTasks(any(that: isA<List<Task>>()))).called(1);
      verify(() => mockSaveXp(10)).called(1);
    });

    test('completeTask returns false when task is already completed', () async {
      const task = Task(
        id: '1',
        title: 'Task 1',
        completed: true,
        subtasks: [SubTask(title: 'sub', done: true)],
      );
      notifier.setAll([task]);

      final result = await notifier.completeTask('1');

      expect(result, isFalse);
      verifyNever(() => mockSaveTasks(any()));
    });

    test('completeTask returns true and persists when task is incomplete',
        () async {
      const task = Task(
        id: '1',
        title: 'Task 1',
        subtasks: [SubTask(title: 'sub', done: false)],
      );
      notifier.setAll([task]);

      final result = await notifier.completeTask('1');

      expect(result, isTrue);
      expect(notifier.state.first.completed, isTrue);
      verify(() => mockSaveTasks(any(that: isA<List<Task>>()))).called(1);
      verify(() => mockSaveXp(10)).called(1);
    });
  });
}
