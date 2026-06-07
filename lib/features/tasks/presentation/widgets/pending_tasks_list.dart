import 'package:flutter/material.dart';

import '../../domain/entities/task.dart';
import '../../../../core/services/feedback_service.dart';

class PendingTasksList extends StatelessWidget {
  final List<Task> tasks;
  final Future<void> Function(String taskId) onRemove;

  const PendingTasksList({
    super.key,
    required this.tasks,
    required this.onRemove,
  });

  Future<void> _confirmRemove(BuildContext context, Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover tarefa?'),
        content: Text(
          'Tem certeza que quer remover "${task.title}"?\nEssa ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      FeedbackService.click();
      await onRemove(task.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final task = tasks[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            child: Card(
              elevation: 0,
              color: colorScheme.surfaceContainerLow.withOpacity(0.6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(
                  color: colorScheme.outlineVariant.withOpacity(0.3),
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
                leading: Icon(
                  Icons.circle_outlined,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
                title: Text(
                  task.title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    size: 22,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  tooltip: 'Remover tarefa',
                  onPressed: () => _confirmRemove(context, task),
                ),
              ),
            ),
          );
        },
        childCount: tasks.length,
      ),
    );
  }
}
