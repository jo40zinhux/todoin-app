import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/feedback_service.dart';
import '../../../ai/domain/subtask_suggestions.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../ai/domain/usecases/suggest_subtasks.dart';
import '../../../ai/presentation/providers/ai_provider.dart';
import '../../../billing/presentation/providers/billing_provider.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/subtask.dart';
import '../../domain/entities/task.dart';
import '../../domain/task_rules.dart';
import '../utils/task_type_display.dart';

typedef AddTaskCallback = void Function(
  String title,
  TaskType type, {
  List<SubTask>? subtasks,
});

class AddTaskSheet extends ConsumerStatefulWidget {
  final AddTaskCallback onAdd;

  const AddTaskSheet({super.key, required this.onAdd});

  @override
  ConsumerState<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends ConsumerState<AddTaskSheet> {
  final _controller = TextEditingController();
  TaskType _selectedType = TaskType.general;
  bool _manualSelection = false;
  List<SubTask> _previewSubtasks = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _previewSubtasks = generateSubtasks('', _selectedType);
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _controller.text;

    if (!_manualSelection) {
      final detected = detectTaskType(text);
      if (detected != _selectedType) {
        setState(() => _selectedType = detected);
      }
    }

    setState(() {
      _previewSubtasks = _buildPreview(text.isEmpty ? '...' : text);
    });
  }

  List<SubTask> _buildPreview(String text) {
    final isPro = ref.read(entitlementNotifierProvider).value?.isPro ?? false;
    if (isPro && text != '...') {
      return suggestPersonalizedSubtasks(text, _selectedType);
    }
    return generateSubtasks(text, _selectedType);
  }

  void _onTypeSelected(TaskType type) {
    FeedbackService.click();
    setState(() {
      _selectedType = type;
      _manualSelection = true;
      final text = _controller.text;
      _previewSubtasks = _buildPreview(text.isEmpty ? '...' : text);
    });
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    FeedbackService.click();
    final title = _controller.text.trim();
    if (title.isEmpty) return;

    final isPro = ref.read(entitlementNotifierProvider).value?.isPro ?? false;
    List<SubTask>? subtasks;

    if (isPro) {
      setState(() => _isSubmitting = true);
      try {
        final result = await ref.read(suggestSubtasksProvider)(
          SuggestSubtasksParams(title: title, type: _selectedType),
        );
        subtasks = result.subtasks;
        AnalyticsService.instance.aiSubtasksGenerated(
          source: result.source.name,
        );
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
    }

    if (!mounted) return;
    widget.onAdd(title, _selectedType, subtasks: subtasks);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 20, 24, 20 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'O que você quer começar?',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Escreva e a gente divide em passos pra você.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'Ex: Estudar matemática',
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 14,
              ),
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                TaskType.study,
                TaskType.action,
                TaskType.organizing,
                TaskType.general,
              ].map((type) {
                final isSelected = _selectedType == type;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text('${taskTypeIcon(type)} ${taskTypeName(type)}'),
                    selected: isSelected,
                    onSelected: (_) => _onTypeSelected(type),
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    selectedColor: colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide.none,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outlineVariant.withOpacity(0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Você vai começar assim:',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ..._previewSubtasks.map(
                  (st) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: colorScheme.outline,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            st.title,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: _isSubmitting ? null : () => _submit(),
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Começar 🚀',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
