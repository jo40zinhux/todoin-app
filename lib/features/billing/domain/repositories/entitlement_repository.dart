import '../entities/entitlement.dart';

export '../entities/entitlement.dart' show ProPlanType;

abstract class EntitlementRepository {
  Future<Entitlement> getEntitlement();
  Future<void> saveEntitlement(Entitlement entitlement);
  Future<void> grantPro(ProPlanType planType);
  Future<void> revokePro();
  Future<void> incrementTasksCompleted();
  Future<void> markPaywallDismissed();
}
