import '../../domain/entities/task.dart';
import '../../domain/entities/tasks_load_result.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_datasource.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource localDataSource;

  TaskRepositoryImpl({required this.localDataSource});

  @override
  Future<TasksLoadResult> getTasks() async {
    final result = await localDataSource.getTasks();
    return TasksLoadResult(
      tasks: result.tasks.map((model) => model.toEntity()).toList(),
      recoveredFromCorruption: result.recoveredFromCorruption,
    );
  }

  @override
  Future<void> saveTasks(List<Task> tasks) async {
    final taskModels = tasks.map((t) => TaskModel.fromEntity(t)).toList();
    await localDataSource.saveTasks(taskModels);
  }

  @override
  Future<int> getXp() async {
    return await localDataSource.getXp();
  }

  @override
  Future<void> saveXp(int xp) async {
    await localDataSource.saveXp(xp);
  }
}
