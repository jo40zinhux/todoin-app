import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoin_focus_app/features/backup/domain/repositories/backup_repository.dart';
import 'package:todoin_focus_app/features/sync/data/datasources/sync_local_datasource.dart';
import 'package:todoin_focus_app/features/sync/data/datasources/sync_remote_datasource.dart';
import 'package:todoin_focus_app/features/sync/data/repositories/sync_repository_impl.dart';
import 'package:todoin_focus_app/features/sync/domain/gateways/sync_auth_gateway.dart';
import 'package:todoin_focus_app/features/sync/domain/repositories/sync_repository.dart';

class MockBackupRepository extends Mock implements BackupRepository {}

class MockSyncRemoteDataSource extends Mock implements SyncRemoteDataSource {}

class MockSyncAuthGateway extends Mock implements SyncAuthGateway {}

void main() {
  late SyncRepositoryImpl repository;
  late SyncLocalDataSource local;
  late MockBackupRepository backupRepository;
  late MockSyncRemoteDataSource remote;
  late MockSyncAuthGateway authService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'todoin_cloud_sync_enabled': true,
    });
    final prefs = await SharedPreferences.getInstance();
    local = SyncLocalDataSource(prefs);
    backupRepository = MockBackupRepository();
    remote = MockSyncRemoteDataSource();
    authService = MockSyncAuthGateway();
    repository = SyncRepositoryImpl(
      local: local,
      remote: remote,
      backupRepository: backupRepository,
      authService: authService,
    );
  });

  test('returns skipped when user is not Pro', () async {
    final result = await repository.syncNow(isPro: false);

    expect(result, SyncResult.skipped);
    verifyNever(() => backupRepository.createBackup());
  });

  test('returns skipped when cloud sync is disabled', () async {
    await local.setEnabled(false);

    final result = await repository.syncNow(isPro: true);

    expect(result, SyncResult.skipped);
    verifyNever(() => backupRepository.createBackup());
  });

  test('returns skipped when Supabase is not configured', () async {
    final result = await repository.syncNow(isPro: true);

    expect(result, SyncResult.skipped);
  });
}
