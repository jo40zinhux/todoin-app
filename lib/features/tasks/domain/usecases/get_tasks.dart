import '../../../../core/usecases/usecase.dart';
import '../entities/tasks_load_result.dart';
import '../repositories/task_repository.dart';

class GetTasks implements UseCase<TasksLoadResult, NoParams> {
  final TaskRepository repository;

  GetTasks(this.repository);

  @override
  Future<TasksLoadResult> call(NoParams params) async {
    return repository.getTasks();
  }
}
