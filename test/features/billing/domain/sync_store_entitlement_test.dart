import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todoin_focus_app/features/billing/domain/entities/billing_result.dart';
import 'package:todoin_focus_app/features/billing/domain/entities/entitlement.dart';
import 'package:todoin_focus_app/features/billing/domain/gateways/billing_gateway.dart';
import 'package:todoin_focus_app/features/billing/domain/repositories/entitlement_repository.dart';
import 'package:todoin_focus_app/features/billing/domain/usecases/sync_store_entitlement.dart';
import 'package:todoin_focus_app/core/usecases/usecase.dart';

class MockEntitlementRepository extends Mock implements EntitlementRepository {}

class MockBillingGateway extends Mock implements BillingGateway {}

void main() {
  late MockEntitlementRepository repository;
  late MockBillingGateway billing;
  late SyncStoreEntitlement useCase;

  setUp(() {
    repository = MockEntitlementRepository();
    billing = MockBillingGateway();
    useCase = SyncStoreEntitlement(repository, billing);
    registerFallbackValue(ProPlanType.yearly);
  });

  test('returns false when store unavailable', () async {
    when(() => billing.isStoreAvailable).thenReturn(false);

    final result = await useCase(NoParams());

    expect(result, isFalse);
    verifyNever(() => billing.syncEntitlementFromStore());
    verifyNever(() => repository.revokePro());
  });

  test('grants pro when store confirms subscription', () async {
    when(() => billing.isStoreAvailable).thenReturn(true);
    when(() => billing.syncEntitlementFromStore()).thenAnswer(
      (_) async => BillingResult.granted(ProPlanType.monthly),
    );
    when(() => repository.grantPro(any())).thenAnswer((_) async {});

    final result = await useCase(NoParams());

    expect(result, isTrue);
    verify(() => repository.grantPro(ProPlanType.monthly)).called(1);
    verifyNever(() => repository.revokePro());
  });

  test('revokes only when confirmed no subscription', () async {
    when(() => billing.isStoreAvailable).thenReturn(true);
    when(() => billing.syncEntitlementFromStore()).thenAnswer(
      (_) async => const BillingResult(success: false),
    );
    when(() => repository.revokePro()).thenAnswer((_) async {});

    await useCase(NoParams());

    verify(() => repository.revokePro()).called(1);
  });

  test('does not revoke on network failure', () async {
    when(() => billing.isStoreAvailable).thenReturn(true);
    when(() => billing.syncEntitlementFromStore()).thenAnswer(
      (_) async => BillingResult.failure('offline'),
    );

    await useCase(NoParams());

    verifyNever(() => repository.revokePro());
  });

  test('does not revoke when store unavailable flag', () async {
    when(() => billing.isStoreAvailable).thenReturn(true);
    when(() => billing.syncEntitlementFromStore()).thenAnswer(
      (_) async => BillingResult.storeUnavailable(),
    );

    await useCase(NoParams());

    verifyNever(() => repository.revokePro());
  });
}
