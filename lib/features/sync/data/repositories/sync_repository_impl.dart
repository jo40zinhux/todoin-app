import '../../../../core/config/sync_config.dart';
import '../../../../core/services/crash_reporting_service.dart';
import '../../domain/gateways/sync_auth_gateway.dart';
import '../../../backup/domain/entities/app_backup.dart';
import '../../../backup/domain/repositories/backup_repository.dart';
import '../../domain/entities/sync_auth_session.dart';
import '../../domain/repositories/sync_repository.dart';
import '../datasources/sync_local_datasource.dart';
import '../datasources/sync_remote_datasource.dart'
    show SyncRemoteDataSource, SyncRemoteException;

class SyncRepositoryImpl implements SyncRepository {
  final SyncLocalDataSource local;
  final SyncRemoteDataSource remote;
  final BackupRepository backupRepository;
  final SyncAuthGateway authService;

  SyncRepositoryImpl({
    required this.local,
    required this.remote,
    required this.backupRepository,
    required this.authService,
  });

  @override
  Future<bool> isEnabled() async => local.isEnabled;

  @override
  Future<void> setEnabled(bool value) => local.setEnabled(value);

  @override
  Future<String> getDeviceId() => local.getOrCreateDeviceId();

  @override
  Future<SyncResult> syncNow({required bool isPro}) async {
    if (!isPro || !SyncConfig.isConfigured || !local.isEnabled) {
      return SyncResult.skipped;
    }

    try {
      final session = await authService.ensureSession();
      if (session == null || !session.isValid) {
        throw const SyncRemoteException(
          'Não foi possível autenticar para sincronizar.',
        );
      }

      final deviceId = await local.getOrCreateDeviceId();
      final localBackup = await backupRepository.createBackup();
      final localUpdatedAt = DateTime.parse(localBackup.exportedAt);
      final remoteRecord = await remote.fetch(
        deviceId: deviceId,
        session: session,
      );

      if (remoteRecord == null) {
        await _push(
          deviceId: deviceId,
          backup: localBackup,
          updatedAt: localUpdatedAt,
          session: session,
        );
        return SyncResult.pushed;
      }

      if (remoteRecord.updatedAt.isAfter(localUpdatedAt)) {
        await backupRepository.restoreBackup(
          AppBackup.fromJson(remoteRecord.payload),
        );
        await local.setLastSyncedAt(remoteRecord.updatedAt);
        return SyncResult.pulled;
      }

      if (localUpdatedAt.isAfter(remoteRecord.updatedAt)) {
        await _push(
          deviceId: deviceId,
          backup: localBackup,
          updatedAt: localUpdatedAt,
          session: session,
        );
        return SyncResult.pushed;
      }

      return SyncResult.upToDate;
    } catch (e, st) {
      CrashReportingService.instance.recordError(e, st, reason: 'cloud_sync');
      return SyncResult.failed;
    }
  }

  Future<void> _push({
    required String deviceId,
    required AppBackup backup,
    required DateTime updatedAt,
    required SyncAuthSession session,
  }) async {
    await remote.upsert(
      deviceId: deviceId,
      payload: backup.toJson(),
      updatedAt: updatedAt,
      session: session,
    );
    await local.setLastSyncedAt(updatedAt);
  }
}
