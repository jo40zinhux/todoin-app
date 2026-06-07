import '../entities/task.dart';
import '../entities/tasks_load_result.dart';

abstract class TaskRepository {
  Future<TasksLoadResult> getTasks();
  Future<void> saveTasks(List<Task> tasks);
  Future<int> getXp();
  Future<void> saveXp(int xp);
}
