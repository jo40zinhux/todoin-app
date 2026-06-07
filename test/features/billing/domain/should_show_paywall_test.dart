import 'package:flutter_test/flutter_test.dart';
import 'package:todoin_focus_app/features/billing/domain/entities/entitlement.dart';
import 'package:todoin_focus_app/features/billing/domain/usecases/should_show_paywall.dart';

void main() {
  late ShouldShowPaywall shouldShowPaywall;

  setUp(() {
    shouldShowPaywall = ShouldShowPaywall();
  });

  test('never shows paywall for pro users', () async {
    final result = await shouldShowPaywall(ShouldShowPaywallParams(
      entitlement: const Entitlement(isPro: true, tasksCompletedCount: 10),
    ));

    expect(result, isFalse);
  });

  test('shows paywall after 3 completions for free users', () async {
    final result = await shouldShowPaywall(ShouldShowPaywallParams(
      entitlement: const Entitlement(isPro: false, tasksCompletedCount: 3),
    ));

    expect(result, isTrue);
  });

  test('does not show paywall if user dismissed after trigger', () async {
    final result = await shouldShowPaywall(ShouldShowPaywallParams(
      entitlement: const Entitlement(
        isPro: false,
        tasksCompletedCount: 5,
        paywallDismissedAfterTrigger: true,
      ),
    ));

    expect(result, isFalse);
  });

  test('shows paywall on explicit trigger', () async {
    final result = await shouldShowPaywall(ShouldShowPaywallParams(
      entitlement: const Entitlement(isPro: false, tasksCompletedCount: 0),
      explicitTrigger: PaywallTrigger.taskLimit,
    ));

    expect(result, isTrue);
  });
}
