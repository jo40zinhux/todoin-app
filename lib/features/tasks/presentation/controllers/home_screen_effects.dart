import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_state_reload_provider.dart';
import '../../../../core/services/widget_data_service.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../billing/domain/entities/entitlement.dart';
import '../../../billing/presentation/providers/billing_provider.dart';
import '../../../stats/presentation/providers/stats_provider.dart';
import '../../../sync/domain/repositories/sync_repository.dart';
import '../../../sync/presentation/providers/sync_provider.dart';
import '../providers/tasks_provider.dart';

/// Side effects da Home (sync, widget, cloud) isolados da UI.
class HomeScreenEffects {
  HomeScreenEffects(this.ref);

  final WidgetRef ref;

  Future<void> loadInitialData({
    required VoidCallback onCorruptionRecovered,
  }) async {
    final loadResult = await ref.read(getTasksProvider)(NoParams());
    final xp = await ref.read(getXpProvider)(NoParams());
    ref.read(tasksNotifierProvider.notifier).setAll(loadResult.tasks);
    ref.read(xpNotifierProvider.notifier).setXp(xp);
    await ref.read(entitlementNotifierProvider.notifier).load();
    await ref.read(statsNotifierProvider.notifier).load();
    await runCloudSyncIfNeeded();
    await syncWidget();

    if (loadResult.recoveredFromCorruption) {
      onCorruptionRecovered();
    }
  }

  Future<void> runCloudSyncIfNeeded() async {
    final isPro =
        ref.read(entitlementNotifierProvider).value?.isPro ?? false;
    final result =
        await ref.read(cloudSyncNotifierProvider.notifier).syncNow(isPro: isPro);

    if (result == SyncResult.pulled) {
      await ref.read(appStateReloadProvider).afterBackupOrCloudPull();
    }
  }

  Future<void> syncWidget() async {
    final entitlement = ref.read(entitlementNotifierProvider).value ??
        const Entitlement(isPro: false);
    final stats = ref.read(statsNotifierProvider).value;
    final tasksNotifier = ref.read(tasksNotifierProvider.notifier);
    final current = tasksNotifier.currentTask;

    await WidgetDataService.instance.update(
      isPro: entitlement.isPro,
      currentTaskTitle: current?.title,
      streak: stats?.streak.currentStreak ?? 0,
      xp: ref.read(xpNotifierProvider),
    );
  }

  void pushCloudSync() {
    final isPro =
        ref.read(entitlementNotifierProvider).value?.isPro ?? false;
    ref.read(cloudSyncNotifierProvider.notifier).syncNow(isPro: isPro);
  }
}
