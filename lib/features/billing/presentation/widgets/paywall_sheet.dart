import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/animations/animation_constants.dart';
import '../../../../core/constants/legal_urls.dart';
import '../../../../core/constants/product_catalog.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/feedback_service.dart';
import '../../domain/entities/subscription_plan.dart';
import '../../domain/usecases/should_show_paywall.dart';

class PaywallSheet extends StatefulWidget {
  final PaywallTrigger trigger;
  final Future<bool> Function(String planId) onPurchase;
  final Future<bool> Function() onRestore;
  final VoidCallback onDismiss;

  const PaywallSheet({
    super.key,
    required this.trigger,
    required this.onPurchase,
    required this.onRestore,
    required this.onDismiss,
  });

  static Future<void> show(
    BuildContext context, {
    required PaywallTrigger trigger,
    required Future<bool> Function(String planId) onPurchase,
    required Future<bool> Function() onRestore,
    required VoidCallback onDismiss,
  }) {
    AnalyticsService.instance.paywallShown(trigger: trigger.name);
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PaywallSheet(
        trigger: trigger,
        onPurchase: onPurchase,
        onRestore: onRestore,
        onDismiss: onDismiss,
      ),
    );
  }

  @override
  State<PaywallSheet> createState() => _PaywallSheetState();
}

class _PaywallSheetState extends State<PaywallSheet> {
  String? _selectedPlanId = ProductCatalog.plans
      .firstWhere((p) => p.isPopular)
      .id;
  bool _isPurchasing = false;
  bool _isRestoring = false;

  String get _headline {
    switch (widget.trigger) {
      case PaywallTrigger.taskLimit:
        return 'Você está no limite do plano gratuito';
      case PaywallTrigger.afterCompletions:
        return 'Você está indo bem! Quer ir além?';
      case PaywallTrigger.customTimer:
        return 'Timers personalizados são Pro';
    }
  }

  Future<void> _purchase() async {
    if (_selectedPlanId == null || _isPurchasing) return;
    setState(() => _isPurchasing = true);
    FeedbackService.click();
    AnalyticsService.instance.purchaseStarted(planId: _selectedPlanId!);

    final success = await widget.onPurchase(_selectedPlanId!);
    if (!mounted) return;

    setState(() => _isPurchasing = false);
    if (success) {
      AnalyticsService.instance.purchaseCompleted(planId: _selectedPlanId!);
      Navigator.of(context).pop();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Não foi possível concluir a compra. Tente de novo.'),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'toDoin Pro',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ).animate().fadeIn(duration: AppAnimations.normal),
          const SizedBox(height: 8),
          Text(
            _headline,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withOpacity( 0.7),
            ),
          ),
          const SizedBox(height: 20),
          _FeatureRow(
            icon: Icons.all_inclusive_rounded,
            text: 'Tarefas ilimitadas',
          ),
          _FeatureRow(
            icon: Icons.timer_outlined,
            text: 'Timers de 2, 5, 10 e 15 min',
          ),
          _FeatureRow(
            icon: Icons.insights_outlined,
            text: 'Histórico e progresso semanal completo',
          ),
          const SizedBox(height: 16),
          ...ProductCatalog.plans.map((plan) => _PlanTile(
                plan: plan,
                selected: _selectedPlanId == plan.id,
                onTap: () {
                  FeedbackService.click();
                  setState(() => _selectedPlanId = plan.id);
                },
              )),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _isPurchasing ? null : _purchase,
            child: _isPurchasing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Continuar com Pro'),
          ),
          TextButton(
            onPressed: () {
              FeedbackService.click();
              widget.onDismiss();
              Navigator.of(context).pop();
            },
            child: const Text('Agora não'),
          ),
          TextButton(
            onPressed: _isRestoring
                ? null
                : () async {
                    setState(() => _isRestoring = true);
                    final restored = await widget.onRestore();
                    if (!mounted) return;
                    setState(() => _isRestoring = false);
                    if (restored) Navigator.of(context).pop();
                  },
            child: _isRestoring
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Restaurar compras'),
          ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => _openUrl(LegalUrls.termsOfUse),
                  child: const Text('Termos'),
                ),
                TextButton(
                  onPressed: () => _openUrl(LegalUrls.privacyPolicy),
                  child: const Text('Privacidade'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  final SubscriptionPlan plan;
  final bool selected;
  final VoidCallback onTap;

  const _PlanTile({
    required this.plan,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected
            ? colorScheme.primaryContainer.withOpacity( 0.5)
            : colorScheme.surfaceContainerHighest.withOpacity( 0.5),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            plan.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (plan.isPopular) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Popular',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (plan.subtitle != null)
                        Text(
                          plan.subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity( 0.6),
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  plan.priceLabel,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
