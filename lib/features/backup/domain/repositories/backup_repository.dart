import '../entities/app_backup.dart';

abstract class BackupRepository {
  Future<AppBackup> createBackup();
  Future<void> restoreBackup(AppBackup backup);
  String encode(AppBackup backup);
  AppBackup decode(String raw);
}
