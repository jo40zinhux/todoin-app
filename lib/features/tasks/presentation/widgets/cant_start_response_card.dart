import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CantStartResponseCard extends StatelessWidget {
  final String emoji;
  final String headline;
  final String body;
  final String tip;
  final String ctaLabel;
  final Color? ctaColor;
  final VoidCallback onCta;

  const CantStartResponseCard({
    super.key,
    required this.emoji,
    required this.headline,
    required this.body,
    required this.tip,
    required this.ctaLabel,
    required this.ctaColor,
    required this.onCta,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 48))
            .animate()
            .scale(
              begin: const Offset(0.6, 0.6),
              end: const Offset(1.0, 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.elasticOut,
            ),
        const SizedBox(height: 12),
        Text(
          headline,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          body,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                size: 16,
                color: colorScheme.tertiary,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  tip,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: FilledButton(
            onPressed: onCta,
            style: FilledButton.styleFrom(
              backgroundColor: ctaColor ?? colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              ctaLabel,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        )
            .animate()
            .fadeIn(
              delay: const Duration(milliseconds: 150),
              duration: const Duration(milliseconds: 300),
            )
            .slideY(
              begin: 0.15,
              end: 0,
              delay: const Duration(milliseconds: 150),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            ),
      ],
    );
  }
}
