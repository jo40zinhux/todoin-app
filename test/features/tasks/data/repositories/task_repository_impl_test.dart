import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todoin_focus_app/features/tasks/data/datasources/task_local_datasource.dart';
import 'package:todoin_focus_app/features/tasks/data/models/task_model.dart';
import 'package:todoin_focus_app/features/tasks/data/models/tasks_read_result.dart';
import 'package:todoin_focus_app/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:todoin_focus_app/features/tasks/domain/entities/task.dart';

class MockTaskLocalDataSource extends Mock implements TaskLocalDataSource {}

void main() {
  late TaskRepositoryImpl repository;
  late MockTaskLocalDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockTaskLocalDataSource();
    repository = TaskRepositoryImpl(localDataSource: mockDataSource);
  });

  group('TaskRepositoryImpl Tests', () {
    final tTaskModels = [
      const TaskModel(id: '1', title: 'Task 1', subtasks: []),
    ];
    final tTasks = [
      const Task(id: '1', title: 'Task 1', subtasks: []),
    ];

    test('should return list of Task entities when getTasks is called', () async {
      when(() => mockDataSource.getTasks()).thenAnswer(
        (_) async => TasksReadResult(tasks: tTaskModels),
      );

      final result = await repository.getTasks();

      expect(result.tasks, equals(tTasks));
      expect(result.tasks.first, isA<Task>());
      expect(result.recoveredFromCorruption, isFalse);
      verify(() => mockDataSource.getTasks()).called(1);
    });

    test('should call saveTasks on DataSource when saving Task Entities',
        () async {
      when(() => mockDataSource.saveTasks(any())).thenAnswer((_) async => {});

      await repository.saveTasks(tTasks);

      // Verify if the conversion correctly happens and calls the mock
      verify(() => mockDataSource.saveTasks(any(that: isA<List<TaskModel>>())))
          .called(1);
    });

    test('should return XP when getXp is called', () async {
      when(() => mockDataSource.getXp()).thenAnswer((_) async => 20);

      final result = await repository.getXp();

      expect(result, 20);
      verify(() => mockDataSource.getXp()).called(1);
    });

    test('should call saveXp on DataSource when saving XP', () async {
      when(() => mockDataSource.saveXp(any())).thenAnswer((_) async => {});

      await repository.saveXp(30);

      verify(() => mockDataSource.saveXp(30)).called(1);
    });
  });
}
