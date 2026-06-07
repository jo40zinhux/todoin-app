import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/animations/animation_constants.dart';
import '../../domain/entities/streak_state.dart';
import '../../domain/entities/weekly_stats.dart';

class ProgressSheet extends StatelessWidget {
  final StreakState streak;
  final WeeklyStats weekly;
  final bool isPro;
  final VoidCallback? onUpgrade;

  const ProgressSheet({
    super.key,
    required this.streak,
    required this.weekly,
    required this.isPro,
    this.onUpgrade,
  });

  static Future<void> show(
    BuildContext context, {
    required StreakState streak,
    required WeeklyStats weekly,
    required bool isPro,
    VoidCallback? onUpgrade,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ProgressSheet(
        streak: streak,
        weekly: weekly,
        isPro: isPro,
        onUpgrade: onUpgrade,
      ),
    );
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outline.withOpacity( 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Seu progresso',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ).animate().fadeIn(duration: AppAnimations.normal),
          const SizedBox(height: 8),
          Text(
            'Sem pressão — só o que você já conquistou.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity( 0.7),
            ),
          ),
          const SizedBox(height: 24),
          _StatCard(
            icon: Icons.local_fire_department_outlined,
            label: 'Sequência gentil',
            value: streak.currentStreak > 0
                ? '${streak.currentStreak} dia${streak.currentStreak == 1 ? '' : 's'}'
                : 'Comece hoje',
            subtitle: streak.longestStreak > 0
                ? 'Melhor: ${streak.longestStreak} dias'
                : null,
          ),
          const SizedBox(height: 12),
          _StatCard(
            icon: Icons.check_circle_outline,
            label: 'Tarefas concluídas esta semana',
            value: '${weekly.tasksCompleted}',
          ),
          const SizedBox(height: 12),
          _StatCard(
            icon: Icons.play_circle_outline,
            label: 'Tarefas iniciadas esta semana',
            value: '${weekly.tasksStarted}',
          ),
          if (isPro) ...[
            const SizedBox(height: 12),
            _StatCard(
              icon: Icons.star_outline,
              label: 'XP ganho esta semana',
              value: '${weekly.xpEarned}',
            ),
          ] else ...[
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onUpgrade,
              child: const Text('Ver histórico completo com Pro'),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity( 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity( 0.6),
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
