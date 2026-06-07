import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoin_focus_app/features/billing/data/datasources/entitlement_local_datasource.dart';
import 'package:todoin_focus_app/features/billing/data/repositories/entitlement_repository_impl.dart';
import 'package:todoin_focus_app/features/billing/domain/entities/entitlement.dart';

void main() {
  late EntitlementRepositoryImpl repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    repository = EntitlementRepositoryImpl(EntitlementLocalDataSource(prefs));
  });

  test('revokePro clears pro status and plan type', () async {
    await repository.grantPro(ProPlanType.yearly);

    await repository.revokePro();
    final entitlement = await repository.getEntitlement();

    expect(entitlement.isPro, isFalse);
    expect(entitlement.planType, ProPlanType.none);
  });

  test('revokePro is no-op when user is already free', () async {
    final before = await repository.getEntitlement();

    await repository.revokePro();
    final after = await repository.getEntitlement();

    expect(after, equals(before));
  });
}
