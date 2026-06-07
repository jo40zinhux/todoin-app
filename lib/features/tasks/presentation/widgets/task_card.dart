import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/animations/animated_list_item.dart';
import '../../../../core/animations/animation_constants.dart';
import '../../../../core/services/feedback_service.dart';
import '../utils/task_type_display.dart';
import '../../domain/entities/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final void Function(int index) onToggleSubtask;
  final VoidCallback onStartTimer;
  final VoidCallback onCantStart;
  final VoidCallback onComplete;
  final String timerButtonLabel;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggleSubtask,
    required this.onStartTimer,
    required this.onCantStart,
    required this.onComplete,
    this.timerButtonLabel = 'Começar por 2 minutos',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedListItem(
      duration: AppAnimations.normal,
      slideOffset: AppAnimations.slideFromBelow,
      child: Card(
        elevation: 0,
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.5),
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scaleXY(
                        begin: 1.0,
                        end: 1.5,
                        duration: AppAnimations.slow,
                        curve: Curves.easeInOut,
                      ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      task.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${taskTypeIcon(task.type)} ${taskTypeName(task.type)}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ...List.generate(task.subtasks.length, (index) {
                final sub = task.subtasks[index];
                return AnimatedListItem(
                  delay: AppAnimations.staggerOffset * index,
                  duration: AppAnimations.medium,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => onToggleSubtask(index),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 4,
                        ),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: AppAnimations.fast,
                              curve: AppAnimations.tapScale,
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: sub.done
                                    ? colorScheme.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: sub.done
                                      ? colorScheme.primary
                                      : colorScheme.outline,
                                  width: 2,
                                ),
                              ),
                              child: sub.done
                                  ? Icon(
                                      Icons.check,
                                      size: 16,
                                      color: colorScheme.onPrimary,
                                    )
                                      .animate()
                                      .scale(
                                        begin: const Offset(0.3, 0.3),
                                        end: const Offset(1.0, 1.0),
                                        duration: AppAnimations.fast,
                                        curve: AppAnimations.bounceEntry,
                                      )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AnimatedDefaultTextStyle(
                                duration: AppAnimations.fast,
                                curve: Curves.easeOut,
                                style:
                                    (theme.textTheme.bodyMedium ?? const TextStyle())
                                        .copyWith(
                                  decoration: sub.done
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  color: sub.done
                                      ? colorScheme.onSurfaceVariant
                                      : colorScheme.onSurface,
                                ),
                                child: Text(sub.title),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: () {
                    FeedbackService.click();
                    onStartTimer();
                  },
                  icon: const Icon(Icons.play_arrow_rounded, size: 28),
                  label: Text(
                    timerButtonLabel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scaleXY(
                    begin: 1.0,
                    end: 1.05,
                    duration: AppAnimations.slow,
                    curve: Curves.easeInOut,
                  ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        FeedbackService.click();
                        onCantStart();
                      },
                      icon: Icon(
                        Icons.sentiment_dissatisfied_rounded,
                        size: 20,
                        color: colorScheme.secondary,
                      ),
                      label: Text(
                        'Preciso de ajuda',
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.secondary,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        side: BorderSide(color: colorScheme.outlineVariant),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: () {
                        FeedbackService.click();
                        onComplete();
                      },
                      icon: const Icon(
                        Icons.check_circle_outline_rounded,
                        size: 20,
                      ),
                      label: const Text(
                        'Terminei 🙌',
                        style: TextStyle(fontSize: 13),
                      ),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
