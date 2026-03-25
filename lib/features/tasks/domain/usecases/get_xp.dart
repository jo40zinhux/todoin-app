import '../../../../core/usecases/usecase.dart';
import '../repositories/task_repository.dart';

class GetXp implements UseCase<int, NoParams> {
  final TaskRepository repository;

  GetXp(this.repository);

  @override
  Future<int> call(NoParams params) async {
    return await repository.getXp();
  }
}
