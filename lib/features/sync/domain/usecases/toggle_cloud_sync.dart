import '../../../../core/usecases/usecase.dart';
import '../repositories/sync_repository.dart';

class ToggleCloudSyncParams {
  final bool enabled;
  final bool isPro;

  const ToggleCloudSyncParams({required this.enabled, required this.isPro});
}

class ToggleCloudSync implements UseCase<bool, ToggleCloudSyncParams> {
  final SyncRepository repository;

  ToggleCloudSync(this.repository);

  @override
  Future<bool> call(ToggleCloudSyncParams params) async {
    if (!params.isPro) return false;
    await repository.setEnabled(params.enabled);
    return params.enabled;
  }
}
