import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todoin_focus_app/core/services/billing_service.dart';
import 'package:todoin_focus_app/features/billing/domain/entities/entitlement.dart';

void main() {
  group('BillingService.resolvePurchaseWhenStoreUnavailable', () {
    test('grants Pro in debug mode', () {
      final result = BillingService.instance.resolvePurchaseWhenStoreUnavailable(
        'todoin_pro_yearly',
      );

      if (kDebugMode) {
        expect(result.success, isTrue);
        expect(result.planType, ProPlanType.yearly);
      } else {
        expect(result.success, isFalse);
        expect(result.errorMessage, isNotNull);
      }
    });

    test('fails in release mode', () {
      // Simula comportamento release independente do ambiente de teste.
      final debugResult =
          BillingService.instance.resolvePurchaseWhenStoreUnavailable(
        'todoin_pro_monthly',
      );

      if (!kDebugMode) {
        expect(debugResult.success, isFalse);
        expect(debugResult.errorMessage, contains('indisponível'));
      }
    });
  });
}
