import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/animations/animation_constants.dart';
import '../../../../core/services/feedback_service.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

class HomeHeader extends StatelessWidget {
  final int xp;
  final Key xpAnimKey;
  final int xpAnimBegin;
  final int streak;
  final bool isPro;
  final VoidCallback? onProgressTap;

  const HomeHeader({
    super.key,
    required this.xp,
    required this.xpAnimKey,
    required this.xpAnimBegin,
    this.streak = 0,
    this.isPro = false,
    this.onProgressTap,
  });

  void _openSettings(BuildContext context) {
    FeedbackService.click();
    SettingsScreen.open(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'toDoin',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onProgressTap != null)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    Icons.insights_outlined,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onPressed: onProgressTap,
                  tooltip: 'Progresso',
                ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  Icons.settings_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
                onPressed: () => _openSettings(context),
                tooltip: 'Configurações',
              ),
              _XpBadge(
                xp: xp,
                xpAnimKey: xpAnimKey,
                xpAnimBegin: xpAnimBegin,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Foque no agora',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              if (streak > 0)
                _HeaderChip(
                  label: '🔥 $streak',
                  background: colorScheme.secondaryContainer,
                  foreground: colorScheme.onSecondaryContainer,
                ),
              if (isPro)
                _HeaderChip(
                  label: 'PRO',
                  background: colorScheme.primary,
                  foreground: colorScheme.onPrimary,
                  bold: true,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  final bool bold;

  const _HeaderChip({
    required this.label,
    required this.background,
    required this.foreground,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: foreground,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
            ),
      ),
    );
  }
}

class _XpBadge extends StatelessWidget {
  final int xp;
  final Key xpAnimKey;
  final int xpAnimBegin;

  const _XpBadge({
    required this.xp,
    required this.xpAnimKey,
    required this.xpAnimBegin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedScale(
      key: xpAnimKey,
      scale: 1.0,
      duration: AppAnimations.fast,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star_rounded,
              color: colorScheme.tertiary,
              size: 20,
            ),
            const SizedBox(width: 4),
            TweenAnimationBuilder<double>(
              key: xpAnimKey,
              tween: Tween<double>(
                begin: xpAnimBegin.toDouble(),
                end: xp.toDouble(),
              ),
              duration: AppAnimations.normal,
              curve: Curves.easeOut,
              builder: (_, value, __) => Text(
                '${value.round()} XP',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onTertiaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate(key: xpAnimKey)
        .scaleXY(
          begin: 1.0,
          end: 1.12,
          duration: AppAnimations.fast,
          curve: Curves.easeOut,
        )
        .then()
        .scaleXY(
          begin: 1.12,
          end: 1.0,
          duration: AppAnimations.fast,
          curve: Curves.easeIn,
        );
  }
}
