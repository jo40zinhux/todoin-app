import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todoin_focus_app/features/tasks/domain/entities/task.dart';
import 'package:todoin_focus_app/features/tasks/domain/entities/subtask.dart';
import 'package:todoin_focus_app/features/tasks/domain/usecases/save_tasks.dart';
import 'package:todoin_focus_app/features/tasks/domain/usecases/save_xp.dart';
import 'package:todoin_focus_app/features/tasks/presentation/providers/tasks_provider.dart';

class MockSaveTasks extends Mock implements SaveTasks {}

class MockSaveXp extends Mock implements SaveXp {}

class MockRef extends Mock implements Ref {}

void main() {
  late MockSaveTasks mockSaveTasks;
  late MockSaveXp mockSaveXp;
  late MockRef mockRef;

  setUp(() {
    mockSaveTasks = MockSaveTasks();
    mockSaveXp = MockSaveXp();
    mockRef = MockRef();

    registerFallbackValue(const <Task>[]);
  });

  group('XpNotifier Tests', () {
    test('should add XP and call saveXp', () {
      when(() => mockSaveXp(any())).thenAnswer((_) async => {});
      final notifier = XpNotifier(0, mockSaveXp);

      notifier.addXp(10);

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
      notifier = TasksNotifier([], mockSaveTasks, mockRef);
    });

    test('should add new task', () async {
      await notifier.addTask('Test Task', TaskType.general);

      expect(notifier.state.length, 1);
      expect(notifier.state.first.title, 'Test Task');
      expect(notifier.state.first.subtasks.length, 3);
      verify(() => mockSaveTasks(any(that: isA<List<Task>>()))).called(1);
    });

    test('should remove task', () async {
      const task = Task(id: '1', title: 'Task 1', subtasks: []);
      notifier.setAll([task]);

      await notifier.removeTask('1');

      expect(notifier.state, isEmpty);
      verify(() => mockSaveTasks(any(that: isEmpty))).called(1);
    });

    test('should complete all subtasks and complete main task, issuing XP',
        () async {
      const task = Task(
        id: '1',
        title: 'Task 1',
        subtasks: [SubTask(title: 'sub', done: false)],
      );
      notifier.setAll([task]);

      // Mock the XP notifier
      final xpNotifier = XpNotifier(0, mockSaveXp);
      when(() => mockRef.read(xpNotifierProvider.notifier))
          .thenReturn(xpNotifier);
      when(() => mockSaveXp(any())).thenAnswer((_) async => {});

      final completed = await notifier.toggleSubtask('1', 0);

      expect(completed, isTrue);
      expect(notifier.state.first.completed, isTrue);
      expect(notifier.state.first.subtasks.first.done, isTrue);
      verify(() => mockSaveTasks(any(that: isA<List<Task>>()))).called(1);
      verify(() => mockRef.read(xpNotifierProvider.notifier)).called(1);
      expect(xpNotifier.state, 10);
    });
  });
}
