import '../../../../core/usecases/usecase.dart';
import '../repositories/task_repository.dart';

class SaveXp implements UseCase<void, int> {
  final TaskRepository repository;

  SaveXp(this.repository);

  @override
  Future<void> call(int xp) async {
    return await repository.saveXp(xp);
  }
}
