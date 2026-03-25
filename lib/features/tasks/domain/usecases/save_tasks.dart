import '../../../../core/usecases/usecase.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

class SaveTasks implements UseCase<void, List<Task>> {
  final TaskRepository repository;

  SaveTasks(this.repository);

  @override
  Future<void> call(List<Task> tasks) async {
    return await repository.saveTasks(tasks);
  }
}
