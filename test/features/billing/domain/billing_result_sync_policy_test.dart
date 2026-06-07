import 'package:flutter_test/flutter_test.dart';
import 'package:todoin_focus_app/features/billing/domain/entities/billing_result.dart';
import 'package:todoin_focus_app/features/billing/domain/entities/entitlement.dart';

void main() {
  group('BillingResult sync policy', () {
    test('granted plan does not revoke', () {
      const result = BillingResult(
        success: true,
        planType: ProPlanType.yearly,
      );
      expect(result.shouldRevokeLocalPro, isFalse);
      expect(result.confirmedNoSubscription, isFalse);
    });

    test('confirmed no subscription revokes', () {
      const result = BillingResult(success: false);
      expect(result.confirmedNoSubscription, isTrue);
      expect(result.shouldRevokeLocalPro, isTrue);
    });

    test('network failure does not revoke', () {
      final result = BillingResult.failure('offline');
      expect(result.shouldRevokeLocalPro, isFalse);
      expect(result.confirmedNoSubscription, isFalse);
    });

    test('store unavailable does not revoke', () {
      final result = BillingResult.storeUnavailable();
      expect(result.shouldRevokeLocalPro, isFalse);
    });
  });
}
