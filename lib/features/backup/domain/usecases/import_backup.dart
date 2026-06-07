import '../../../../core/usecases/usecase.dart';
import '../entities/app_backup.dart';
import '../repositories/backup_repository.dart';

class ImportBackupParams {
  final String jsonContent;

  const ImportBackupParams({required this.jsonContent});
}

class ImportBackup implements UseCase<void, ImportBackupParams> {
  final BackupRepository repository;

  ImportBackup(this.repository);

  @override
  Future<void> call(ImportBackupParams params) async {
    final backup = repository.decode(params.jsonContent);
    await repository.restoreBackup(backup);
  }
}
