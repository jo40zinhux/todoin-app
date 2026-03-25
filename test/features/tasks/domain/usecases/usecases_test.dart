import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todoin_focus_app/core/usecases/usecase.dart';
import 'package:todoin_focus_app/features/tasks/domain/entities/task.dart';
import 'package:todoin_focus_app/features/tasks/domain/repositories/task_repository.dart';
import 'package:todoin_focus_app/features/tasks/domain/usecases/get_tasks.dart';
import 'package:todoin_focus_app/features/tasks/domain/usecases/save_tasks.dart';
import 'package:todoin_focus_app/features/tasks/domain/usecases/get_xp.dart';
import 'package:todoin_focus_app/features/tasks/domain/usecases/save_xp.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late MockTaskRepository mockRepository;
  late GetTasks getTasks;
  late SaveTasks saveTasks;
  late GetXp getXp;
  late SaveXp saveXp;

  setUp(() {
    mockRepository = MockTaskRepository();
    getTasks = GetTasks(mockRepository);
    saveTasks = SaveTasks(mockRepository);
    getXp = GetXp(mockRepository);
    saveXp = SaveXp(mockRepository);
  });

  group('Usecases Tests', () {
    final tTasks = [
      const Task(id: '1', title: 'Task 1', subtasks: []),
    ];

    test('should get tasks from repository', () async {
      when(() => mockRepository.getTasks()).thenAnswer((_) async => tTasks);

      final result = await getTasks(NoParams());

      expect(result, tTasks);
      verify(() => mockRepository.getTasks()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should save tasks to repository', () async {
      when(() => mockRepository.saveTasks(any())).thenAnswer((_) async => {});

      await saveTasks(tTasks);

      verify(() => mockRepository.saveTasks(tTasks)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should get XP from repository', () async {
      when(() => mockRepository.getXp()).thenAnswer((_) async => 50);

      final result = await getXp(NoParams());

      expect(result, 50);
      verify(() => mockRepository.getXp()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should save XP to repository', () async {
      when(() => mockRepository.saveXp(any())).thenAnswer((_) async => {});

      await saveXp(100);

      verify(() => mockRepository.saveXp(100)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
