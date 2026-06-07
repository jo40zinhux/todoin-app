import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/entitlement.dart';

class EntitlementLocalDataSource {
  static const _isProKey = 'entitlement_is_pro';
  static const _planTypeKey = 'entitlement_plan_type';
  static const _tasksCompletedKey = 'entitlement_tasks_completed';
  static const _paywallDismissedKey = 'entitlement_paywall_dismissed';

  final SharedPreferences prefs;

  EntitlementLocalDataSource(this.prefs);

  Future<Entitlement> load() async {
    final isPro = prefs.getBool(_isProKey) ?? false;
    final planIndex = prefs.getInt(_planTypeKey) ?? 0;
    final tasksCompleted = prefs.getInt(_tasksCompletedKey) ?? 0;
    final paywallDismissed = prefs.getBool(_paywallDismissedKey) ?? false;

    return Entitlement(
      isPro: isPro,
      planType: ProPlanType.values[planIndex.clamp(0, ProPlanType.values.length - 1)],
      tasksCompletedCount: tasksCompleted,
      paywallDismissedAfterTrigger: paywallDismissed,
    );
  }

  Future<void> save(Entitlement entitlement) async {
    await prefs.setBool(_isProKey, entitlement.isPro);
    await prefs.setInt(_planTypeKey, entitlement.planType.index);
    await prefs.setInt(_tasksCompletedKey, entitlement.tasksCompletedCount);
    await prefs.setBool(
      _paywallDismissedKey,
      entitlement.paywallDismissedAfterTrigger,
    );
  }
}
