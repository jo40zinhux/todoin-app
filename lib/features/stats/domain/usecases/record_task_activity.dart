import '../../../../core/usecases/usecase.dart';
import '../repositories/stats_repository.dart';

class RecordTaskStarted implements UseCase<void, NoParams> {
  final StatsRepository repository;

  RecordTaskStarted(this.repository);

  @override
  Future<void> call(NoParams params) => repository.recordTaskStarted();
}

class RecordTaskCompletedParams {
  final int xpEarned;

  const RecordTaskCompletedParams({required this.xpEarned});
}

class RecordTaskCompleted implements UseCase<void, RecordTaskCompletedParams> {
  final StatsRepository repository;

  RecordTaskCompleted(this.repository);

  @override
  Future<void> call(RecordTaskCompletedParams params) =>
      repository.recordTaskCompleted(xpEarned: params.xpEarned);
}
