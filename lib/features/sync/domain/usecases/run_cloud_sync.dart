import '../../../../core/usecases/usecase.dart';
import '../repositories/sync_repository.dart';

class RunCloudSyncParams {
  final bool isPro;

  const RunCloudSyncParams({required this.isPro});
}

class RunCloudSync implements UseCase<SyncResult, RunCloudSyncParams> {
  final SyncRepository repository;

  RunCloudSync(this.repository);

  @override
  Future<SyncResult> call(RunCloudSyncParams params) =>
      repository.syncNow(isPro: params.isPro);
}
