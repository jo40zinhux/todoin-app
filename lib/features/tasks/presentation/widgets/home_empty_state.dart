import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/animations/animation_constants.dart';
import '../../../../core/services/feedback_service.dart';

class HomeEmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  final bool allCompleted;

  const HomeEmptyState({
    super.key,
    required this.onAdd,
    this.allCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final title = allCompleted ? 'Tudo feito por agora!' : 'Pronto para começar?';
    final subtitle = allCompleted
        ? 'Você completou suas tarefas.\nQuando quiser, comece algo novo.'
        : 'Escreva o que está na sua cabeça.\nA gente divide em passos pequenos pra você.';
    final icon = allCompleted ? Icons.celebration_rounded : Icons.task_alt_rounded;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: colorScheme.primary),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(
                  begin: 1.0,
                  end: 1.06,
                  duration: AppAnimations.slow,
                  curve: Curves.easeInOut,
                ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                FeedbackService.click();
                onAdd();
              },
              icon: const Icon(Icons.add_rounded),
              label: Text(allCompleted ? 'Começar algo novo' : 'Começar algo agora'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
