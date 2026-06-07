import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../billing/domain/usecases/should_show_paywall.dart';
import '../../../billing/presentation/providers/billing_provider.dart';
import '../../../billing/presentation/widgets/paywall_sheet.dart';

Future<void> showSettingsPaywall(BuildContext context, WidgetRef ref) {
  return PaywallSheet.show(
    context,
    trigger: PaywallTrigger.afterCompletions,
    onPurchase: (planId) =>
        ref.read(entitlementNotifierProvider.notifier).purchase(planId),
    onRestore: () => ref.read(entitlementNotifierProvider.notifier).restore(),
    onDismiss: () =>
        ref.read(entitlementNotifierProvider.notifier).dismissPaywall(),
  );
}
