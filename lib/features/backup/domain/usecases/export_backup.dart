import 'dart:convert';

import '../../../../core/usecases/usecase.dart';
import '../repositories/backup_repository.dart';

class ExportBackup implements UseCase<String, NoParams> {
  final BackupRepository repository;

  ExportBackup(this.repository);

  @override
  Future<String> call(NoParams params) async {
    final backup = await repository.createBackup();
    return repository.encode(backup);
  }
}
