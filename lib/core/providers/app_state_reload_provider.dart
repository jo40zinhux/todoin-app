import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/billing/presentation/providers/billing_provider.dart';
import '../../features/reminders/presentation/providers/reminder_provider.dart';
import '../../features/settings/presentation/providers/settings_provider.dart';
import '../../features/stats/presentation/providers/stats_provider.dart';
import '../../features/tasks/presentation/providers/tasks_provider.dart';
import '../usecases/usecase.dart';

/// Recarrega notifiers após restore de backup ou pull de cloud sync.
class AppStateReload {
  AppStateReload(this._ref);

  final Ref _ref;

  Future<void> afterBackupOrCloudPull() async {
    final loadResult = await _ref.read(getTasksProvider)(NoParams());
    _ref.read(tasksNotifierProvider.notifier).setAll(loadResult.tasks);
    final xp = await _ref.read(getXpProvider)(NoParams());
    _ref.read(xpNotifierProvider.notifier).setXp(xp);
    await _ref.read(statsNotifierProvider.notifier).load();
    await _ref.read(settingsNotifierProvider.notifier).load();
    await _ref.read(reminderNotifierProvider.notifier).load();
    await _ref.read(entitlementNotifierProvider.notifier).load();
  }
}

final appStateReloadProvider = Provider<AppStateReload>((ref) {
  return AppStateReload(ref);
});
