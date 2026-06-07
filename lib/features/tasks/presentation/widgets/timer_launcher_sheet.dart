import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/free_tier_limits.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/feedback_service.dart';
import '../../../billing/domain/entities/entitlement.dart';
import '../../../billing/domain/usecases/should_show_paywall.dart';
import '../../../billing/presentation/providers/billing_provider.dart';
import '../../../billing/presentation/widgets/paywall_sheet.dart';
import '../../../billing/presentation/widgets/timer_duration_picker.dart';
import 'timer_widget.dart';

class TimerLauncherSheet extends ConsumerStatefulWidget {
  final String? taskTitle;

  const TimerLauncherSheet({super.key, this.taskTitle});

  static Future<void> show(BuildContext context, {String? taskTitle}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TimerLauncherSheet(taskTitle: taskTitle),
    );
  }

  @override
  ConsumerState<TimerLauncherSheet> createState() =>
      _TimerLauncherSheetState();
}

class _TimerLauncherSheetState extends ConsumerState<TimerLauncherSheet> {
  int _selectedSeconds = FreeTierLimits.defaultTimerSeconds;

  Future<void> _startTimer() async {
    final entitlement =
        ref.read(entitlementNotifierProvider).value ?? const Entitlement(isPro: false);
    final durations =
        await ref.read(getAvailableTimerDurationsProvider)(entitlement);

    if (!durations.contains(_selectedSeconds)) {
      await PaywallSheet.show(
        context,
        trigger: PaywallTrigger.customTimer,
        onPurchase: (planId) =>
            ref.read(entitlementNotifierProvider.notifier).purchase(planId),
        onRestore: () =>
            ref.read(entitlementNotifierProvider.notifier).restore(),
        onDismiss: () =>
            ref.read(entitlementNotifierProvider.notifier).dismissPaywall(),
      );
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pop();
    FeedbackService.click();
    AnalyticsService.instance.timerStarted(seconds: _selectedSeconds);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => TimerWidget(
        durationSeconds: _selectedSeconds,
        taskTitle: widget.taskTitle ?? 'Foco ativo',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final entitlementAsync = ref.watch(entitlementNotifierProvider);

    return entitlementAsync.when(
      loading: () => _sheetFrame(
        context,
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (_, __) => _sheetFrame(
        context,
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Não foi possível carregar o timer. Tente de novo.'),
        ),
      ),
      data: (entitlement) {
        final durationsFuture =
            ref.read(getAvailableTimerDurationsProvider)(entitlement);

        return FutureBuilder<List<int>>(
          future: durationsFuture,
          builder: (context, snapshot) {
            final durations = snapshot.data ??
                [FreeTierLimits.defaultTimerSeconds];

            if (!durations.contains(_selectedSeconds)) {
              _selectedSeconds = durations.first;
            }

            return _sheetFrame(
              context,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Timer de foco',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    entitlement.isPro
                        ? 'Escolha a duração que funciona para você.'
                        : 'Plano gratuito: 2 minutos. Pro desbloqueia mais opções.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TimerDurationPicker(
                    durations: durations,
                    selectedSeconds: _selectedSeconds,
                    onSelected: (seconds) {
                      setState(() => _selectedSeconds = seconds);
                    },
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _startTimer,
                    child: const Text('Iniciar foco'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _sheetFrame(BuildContext context, {required Widget child}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      child: child,
    );
  }
}
