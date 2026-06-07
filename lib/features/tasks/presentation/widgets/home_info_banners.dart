import 'package:flutter/material.dart';

import '../../../../core/constants/free_tier_limits.dart';

class HomeBadDayBanner extends StatelessWidget {
  const HomeBadDayBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Modo dia difícil — só uma tarefa por vez 💜',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}

class HomeFreeTierBanner extends StatelessWidget {
  final int activeCount;

  const HomeFreeTierBanner({super.key, required this.activeCount});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        '$activeCount/${FreeTierLimits.maxActiveTasks} tarefas ativas no plano gratuito',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}
