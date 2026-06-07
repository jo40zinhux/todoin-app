import 'package:flutter/material.dart';

class SettingsPlanCard extends StatelessWidget {
  final bool isPro;
  final VoidCallback onUpgradeTap;

  const SettingsPlanCard({
    super.key,
    required this.isPro,
    required this.onUpgradeTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPro
            ? colorScheme.primaryContainer.withOpacity(0.5)
            : colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            isPro ? Icons.workspace_premium : Icons.person_outline,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPro ? 'Plano Pro ativo' : 'Plano gratuito',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  isPro
                      ? 'Obrigado por apoiar o toDoin 💜'
                      : 'Até 5 tarefas e timer de 2 min',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (!isPro)
            TextButton(
              onPressed: onUpgradeTap,
              child: const Text('Pro'),
            ),
        ],
      ),
    );
  }
}
