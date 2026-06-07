import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/sync_config.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/providers/shared_preferences_provider.dart';
import '../../../../core/services/supabase_auth_service.dart';
import '../../../backup/presentation/providers/backup_provider.dart';
import '../../data/datasources/sync_auth_local_datasource.dart';
import '../../data/datasources/sync_local_datasource.dart';
import '../../data/datasources/sync_remote_datasource.dart';
import '../../data/repositories/sync_repository_impl.dart';
import '../../domain/repositories/sync_repository.dart';
import '../../domain/usecases/run_cloud_sync.dart';
import '../../domain/usecases/toggle_cloud_sync.dart';

final syncLocalDataSourceProvider = Provider<SyncLocalDataSource>((ref) {
  return SyncLocalDataSource(ref.watch(sharedPreferencesProvider));
});

final syncRemoteDataSourceProvider = Provider<SyncRemoteDataSource>((ref) {
  return SyncRemoteDataSource();
});

final syncAuthLocalDataSourceProvider = Provider<SyncAuthLocalDataSource>((ref) {
  return SyncAuthLocalDataSource(ref.watch(sharedPreferencesProvider));
});

final syncRepositoryProvider = Provider<SyncRepository>((ref) {
  SupabaseAuthService.instance.configure(
    ref.watch(syncAuthLocalDataSourceProvider),
  );
  return SyncRepositoryImpl(
    local: ref.watch(syncLocalDataSourceProvider),
    remote: ref.watch(syncRemoteDataSourceProvider),
    backupRepository: ref.watch(backupRepositoryProvider),
    authService: SupabaseAuthService.instance,
  );
});

final toggleCloudSyncProvider = Provider<ToggleCloudSync>((ref) {
  return ToggleCloudSync(ref.watch(syncRepositoryProvider));
});

final runCloudSyncProvider = Provider<RunCloudSync>((ref) {
  return RunCloudSync(ref.watch(syncRepositoryProvider));
});

class CloudSyncState {
  final bool enabled;
  final bool configured;
  final bool isSyncing;
  final String? lastMessage;

  const CloudSyncState({
    this.enabled = false,
    this.configured = false,
    this.isSyncing = false,
    this.lastMessage,
  });

  CloudSyncState copyWith({
    bool? enabled,
    bool? configured,
    bool? isSyncing,
    String? lastMessage,
  }) {
    return CloudSyncState(
      enabled: enabled ?? this.enabled,
      configured: configured ?? this.configured,
      isSyncing: isSyncing ?? this.isSyncing,
      lastMessage: lastMessage,
    );
  }
}

class CloudSyncNotifier extends StateNotifier<CloudSyncState> {
  final SyncRepository _repository;
  final RunCloudSync _runSync;
  final ToggleCloudSync _toggle;

  CloudSyncNotifier(this._repository, this._runSync, this._toggle)
      : super(CloudSyncState(configured: SyncConfig.isConfigured)) {
    _load();
  }

  Future<void> _load() async {
    state = state.copyWith(enabled: await _repository.isEnabled());
  }

  Future<void> setEnabled(bool value, {required bool isPro}) async {
    final ok = await _toggle(ToggleCloudSyncParams(enabled: value, isPro: isPro));
    if (ok) {
      state = state.copyWith(enabled: value);
      AnalyticsService.instance.cloudSyncEnabled(enabled: value);
      if (value) await syncNow(isPro: isPro);
    }
  }

  Future<SyncResult> syncNow({required bool isPro}) async {
    state = state.copyWith(isSyncing: true, lastMessage: null);
    final result = await _runSync(RunCloudSyncParams(isPro: isPro));

    final message = switch (result) {
      SyncResult.pushed => 'Dados salvos na nuvem.',
      SyncResult.pulled => 'Dados atualizados da nuvem.',
      SyncResult.upToDate => 'Tudo sincronizado.',
      SyncResult.skipped => null,
      SyncResult.failed => 'Não foi possível sincronizar agora.',
    };

    state = state.copyWith(isSyncing: false, lastMessage: message);
    if (result != SyncResult.skipped) {
      AnalyticsService.instance.cloudSyncCompleted(result: result.name);
    }
    return result;
  }
}

final cloudSyncNotifierProvider =
    StateNotifierProvider<CloudSyncNotifier, CloudSyncState>((ref) {
  return CloudSyncNotifier(
    ref.watch(syncRepositoryProvider),
    ref.watch(runCloudSyncProvider),
    ref.watch(toggleCloudSyncProvider),
  );
});
