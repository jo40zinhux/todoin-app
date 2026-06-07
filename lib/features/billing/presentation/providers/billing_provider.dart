import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/shared_preferences_provider.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/datasources/entitlement_local_datasource.dart';
import '../../data/gateways/revenue_cat_billing_gateway.dart';
import '../../data/repositories/entitlement_repository_impl.dart';
import '../../domain/gateways/billing_gateway.dart';
import '../../domain/entities/entitlement.dart';
import '../../domain/repositories/entitlement_repository.dart';
import '../../domain/usecases/can_add_task.dart';
import '../../domain/usecases/get_available_timer_durations.dart';
import '../../domain/usecases/get_entitlement.dart';
import '../../domain/usecases/purchase_plan.dart';
import '../../domain/usecases/restore_purchases.dart';
import '../../domain/usecases/should_show_paywall.dart';
import '../../domain/usecases/sync_store_entitlement.dart';

final entitlementDataSourceProvider = Provider<EntitlementLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return EntitlementLocalDataSource(prefs);
});

final entitlementRepositoryProvider = Provider<EntitlementRepository>((ref) {
  return EntitlementRepositoryImpl(ref.watch(entitlementDataSourceProvider));
});

final billingGatewayProvider = Provider<BillingGateway>((ref) {
  return RevenueCatBillingGateway();
});

final getEntitlementProvider = Provider<GetEntitlement>((ref) {
  return GetEntitlement(ref.watch(entitlementRepositoryProvider));
});

final canAddTaskProvider = Provider<CanAddTask>((ref) => CanAddTask());

final getAvailableTimerDurationsProvider =
    Provider<GetAvailableTimerDurations>((ref) => GetAvailableTimerDurations());

final shouldShowPaywallProvider = Provider<ShouldShowPaywall>((ref) {
  return ShouldShowPaywall();
});

final purchasePlanProvider = Provider<PurchasePlan>((ref) {
  return PurchasePlan(
    ref.watch(entitlementRepositoryProvider),
    ref.watch(billingGatewayProvider),
  );
});

final restorePurchasesProvider = Provider<RestorePurchases>((ref) {
  return RestorePurchases(
    ref.watch(entitlementRepositoryProvider),
    ref.watch(billingGatewayProvider),
  );
});

final syncStoreEntitlementProvider = Provider<SyncStoreEntitlement>((ref) {
  return SyncStoreEntitlement(
    ref.watch(entitlementRepositoryProvider),
    ref.watch(billingGatewayProvider),
  );
});

final entitlementNotifierProvider =
    StateNotifierProvider<EntitlementNotifier, AsyncValue<Entitlement>>((ref) {
  return EntitlementNotifier(
    ref.watch(getEntitlementProvider),
    ref.watch(entitlementRepositoryProvider),
    ref.watch(syncStoreEntitlementProvider),
    ref.watch(restorePurchasesProvider),
    ref.watch(purchasePlanProvider),
  );
});

class EntitlementNotifier extends StateNotifier<AsyncValue<Entitlement>> {
  final GetEntitlement _getEntitlement;
  final EntitlementRepository _repository;

  final SyncStoreEntitlement _syncStore;
  final RestorePurchases _restorePurchases;
  final PurchasePlan _purchasePlan;

  EntitlementNotifier(
    this._getEntitlement,
    this._repository,
    this._syncStore,
    this._restorePurchases,
    this._purchasePlan,
  ) : super(const AsyncValue.loading());

  Future<void> load() async {
    try {
      await _syncStore(NoParams());
      final entitlement = await _getEntitlement(NoParams());
      state = AsyncValue.data(entitlement);
      await AnalyticsService.instance.syncUserProfile(
        isPro: entitlement.isPro,
        planType: entitlement.planType.name,
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> purchase(String planId) async {
    final success = await _purchasePlan(PurchasePlanParams(planId: planId));
    if (success) await load();
    return success;
  }

  Future<bool> restore() async {
    final success = await _restorePurchases(NoParams());
    if (success) await load();
    return success;
  }

  Future<void> onTaskCompleted() async {
    await _repository.incrementTasksCompleted();
    await load();
  }

  Future<void> dismissPaywall() async {
    await _repository.markPaywallDismissed();
    await load();
  }
}
