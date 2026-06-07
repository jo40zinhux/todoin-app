import '../../domain/entities/entitlement.dart';
import '../../domain/repositories/entitlement_repository.dart';
import '../datasources/entitlement_local_datasource.dart';

class EntitlementRepositoryImpl implements EntitlementRepository {
  final EntitlementLocalDataSource dataSource;

  EntitlementRepositoryImpl(this.dataSource);

  @override
  Future<Entitlement> getEntitlement() => dataSource.load();

  @override
  Future<void> saveEntitlement(Entitlement entitlement) =>
      dataSource.save(entitlement);

  @override
  Future<void> grantPro(ProPlanType planType) async {
    final current = await dataSource.load();
    await dataSource.save(
      current.copyWith(isPro: true, planType: planType),
    );
  }

  @override
  Future<void> revokePro() async {
    final current = await dataSource.load();
    if (!current.isPro) return;

    await dataSource.save(
      current.copyWith(isPro: false, planType: ProPlanType.none),
    );
  }

  @override
  Future<void> incrementTasksCompleted() async {
    final current = await dataSource.load();
    await dataSource.save(
      current.copyWith(tasksCompletedCount: current.tasksCompletedCount + 1),
    );
  }

  @override
  Future<void> markPaywallDismissed() async {
    final current = await dataSource.load();
    await dataSource.save(
      current.copyWith(paywallDismissedAfterTrigger: true),
    );
  }
}
