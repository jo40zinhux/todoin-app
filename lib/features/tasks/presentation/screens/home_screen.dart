import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/animations/xp_floating_label.dart';
import '../../../../core/animations/animation_constants.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/task_type_helper.dart';
import '../../domain/entities/subtask.dart';
import '../../domain/entities/task.dart';
import '../providers/tasks_provider.dart';
import '../widgets/cant_start_sheet.dart';
import '../widgets/task_card.dart';
import '../widgets/timer_widget.dart';
import '../../../../core/services/feedback_service.dart';
import '../../../settings/presentation/widgets/settings_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;

  // Controls the floating +10 XP label visibility
  bool _showXpLabel = false;

  // Tracks the last known XP to detect changes for the badge pulse
  int _lastXp = 0;
  // Key that changes on XP update to retrigger the pulse animation
  Key _xpAnimKey = const ValueKey(0);

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(milliseconds: 1200));

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final tasks = await ref.read(getTasksProvider)(NoParams());
      final xp = await ref.read(getXpProvider)(NoParams());
      ref.read(tasksNotifierProvider.notifier).setAll(tasks);
      ref.read(xpNotifierProvider.notifier).setXp(xp);
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _showAddTaskSheet() {
    FeedbackService.click();
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddTaskSheet(
        controller: controller,
        onAdd: (title, type) {
          ref.read(tasksNotifierProvider.notifier).addTask(title, type);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _openTimer() {
    FeedbackService.click();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const TimerWidget(),
    );
  }

  void _showCantStartSheet(String? firstSubtaskTitle) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CantStartSheet(
        firstSubtaskTitle: firstSubtaskTitle,
        onStartTimer: _openTimer,
      ),
    );
  }

  void _celebrate() {
    FeedbackService.success();
    _confettiController.play();

    // Show floating +10 XP label then hide it after animation completes
    setState(() => _showXpLabel = true);
    Future.delayed(const Duration(milliseconds: 950), () {
      if (mounted) setState(() => _showXpLabel = false);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(ref.read(tasksNotifierProvider.notifier).randomCelebration),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final xp = ref.watch(xpNotifierProvider);
    final _ = ref.watch(tasksNotifierProvider);
    final tasksNotifier = ref.read(tasksNotifierProvider.notifier);

    // Trigger XP badge pulse whenever XP changes
    if (xp != _lastXp) {
      _lastXp = xp;
      _xpAnimKey = ValueKey(xp);
    }

    final current = tasksNotifier.currentTask;
    final pendingOps = tasksNotifier.pendingTasks;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          SafeArea(
            child: CustomScrollView(
              slivers: [
                // ── Header ───────────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('toDoin',
                                    style: theme.textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: colorScheme.primary)),
                                Text('Foque no agora',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant)),
                              ],
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: Icon(Icons.settings_rounded, color: colorScheme.onSurfaceVariant),
                              onPressed: () {
                                FeedbackService.click();
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) => const SettingsSheet(),
                                );
                              },
                            ),
                          ],
                        ),
                        // ── XP badge with pulse animation ─────────────────
                        AnimatedScale(
                          key: _xpAnimKey,
                          scale: 1.0,
                          duration: AppAnimations.fast,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: colorScheme.tertiaryContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star_rounded,
                                    color: colorScheme.tertiary, size: 22),
                                const SizedBox(width: 6),
                                TweenAnimationBuilder<double>(
                                  key: _xpAnimKey,
                                  tween: Tween<double>(
                                    begin: (_lastXp - 10).toDouble().clamp(0, double.infinity),
                                    end: xp.toDouble(),
                                  ),
                                  duration: AppAnimations.normal,
                                  curve: Curves.easeOut,
                                  builder: (_, value, __) => Text(
                                    '${value.round()} XP',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: colorScheme.onTertiaryContainer),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                            .animate(key: _xpAnimKey)
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
                            ),
                      ],
                    ),
                  ),
                ),

                // ── Content ───────────────────────────────────────────────────
                if (current == null)
                  SliverFillRemaining(
                    child: _EmptyState(onAdd: _showAddTaskSheet),
                  )
                else ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                      child: Text('🎯 Sua tarefa agora',
                          style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurfaceVariant)),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: TaskCard(
                      key: ValueKey(current.id),
                      task: current,
                      onToggleSubtask: (index) async {
                        final completed = await tasksNotifier
                            .toggleSubtask(current.id, index);
                        if (completed && mounted) {
                          _celebrate();
                        } else {
                          FeedbackService.subtaskDone();
                        }
                      },
                      onStartTimer: _openTimer,
                      onCantStart: () {
                        FeedbackService.click();
                        _showCantStartSheet(current.firstIncompleteSub?.title);
                      },
                      onComplete: () {
                        tasksNotifier.completeTask(current.id);
                        _celebrate();
                      },
                    ),
                  ),
                  if (pendingOps.length > 1)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                        child: Text('A seguir',
                            style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurfaceVariant)),
                      ),
                    ),
                  if (pendingOps.length > 1)
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final task = pendingOps[index + 1];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 4),
                            child: Card(
                              elevation: 0,
                              color: colorScheme.surfaceContainerLow
                                  .withOpacity(0.6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                    color: colorScheme.outlineVariant
                                        .withOpacity(0.3)),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 4),
                                leading: Icon(Icons.circle_outlined,
                                    size: 20,
                                    color: colorScheme.onSurfaceVariant),
                                title: Text(task.title,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                        color: colorScheme.onSurfaceVariant)),
                                trailing: IconButton(
                                  icon: Icon(Icons.close_rounded,
                                      size: 20,
                                      color: colorScheme.onSurfaceVariant),
                                  onPressed: () =>
                                      tasksNotifier.removeTask(task.id),
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: pendingOps.length - 1,
                      ),
                    ),
                ],
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),

          // ── Confetti overlay (anchored top-center) ─────────────────────────
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.08,
              numberOfParticles: 18,
              gravity: 0.25,
              shouldLoop: false,
              colors: [
                colorScheme.primary,
                colorScheme.secondary,
                colorScheme.tertiary,
                colorScheme.primaryContainer,
                colorScheme.tertiaryContainer,
              ],
            ),
          ),

          // ── Floating +10 XP label (top-right near XP badge) ───────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 28,
            right: 36,
            child: XpFloatingLabel(
              key: ValueKey(_showXpLabel),
              visible: _showXpLabel,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTaskSheet,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Começar algo'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
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
                  shape: BoxShape.circle),
              child: Icon(Icons.task_alt_rounded,
                  size: 48, color: colorScheme.primary),
            )
                .animate(
                  onPlay: (c) => c.repeat(reverse: true),
                )
                .scaleXY(
                  begin: 1.0,
                  end: 1.06,
                  duration: const Duration(milliseconds: 1400),
                  curve: Curves.easeInOut,
                ),
            const SizedBox(height: 24),
            Text('Pronto para começar?',
                style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface)),
            const SizedBox(height: 8),
            Text(
              'Escreva o que está na sua cabeça.\nA gente divide em passos pequenos pra você.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant, height: 1.5),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                FeedbackService.click();
                onAdd();
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Começar algo agora'),
              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add task bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _AddTaskSheet extends StatefulWidget {
  final TextEditingController controller;
  final void Function(String title, TaskType type) onAdd;

  const _AddTaskSheet({required this.controller, required this.onAdd});

  @override
  State<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<_AddTaskSheet> {
  TaskType _selectedType = TaskType.general;
  bool _manualSelection = false;
  List<SubTask> _previewSubtasks = [];

  @override
  void initState() {
    super.initState();
    _previewSubtasks = generateSubtasks('', _selectedType);
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final text = widget.controller.text;

    if (!_manualSelection) {
      final detected = detectTaskType(text);
      if (detected != _selectedType) {
        setState(() {
          _selectedType = detected;
        });
      }
    }

    setState(() {
      _previewSubtasks =
          generateSubtasks(text.isEmpty ? '...' : text, _selectedType);
    });
  }

  void _onTypeSelected(TaskType type) {
    FeedbackService.click();
    setState(() {
      _selectedType = type;
      _manualSelection = true;
      final text = widget.controller.text;
      _previewSubtasks =
          generateSubtasks(text.isEmpty ? '...' : text, _selectedType);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
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
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Text('O que você quer começar?',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Escreva e a gente divide em passos pra você.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 16),

          TextField(
            controller: widget.controller,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'Ex: Estudar matemática',
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) widget.onAdd(value, _selectedType);
            },
          ),
          const SizedBox(height: 16),

          // Task Type Chips
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
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    side: BorderSide.none,
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 20),

          // Preview Frame
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: colorScheme.outlineVariant.withOpacity(0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Você vai começar assim:',
                  style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ..._previewSubtasks.map((st) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline,
                              size: 16, color: colorScheme.outline),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(st.title,
                                style: theme.textTheme.bodyMedium
                                    ?.copyWith(color: colorScheme.onSurface)),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: () {
                FeedbackService.click();
                if (widget.controller.text.trim().isNotEmpty) {
                  widget.onAdd(widget.controller.text, _selectedType);
                }
              },
              style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16))),
              child: const Text('Começar 🚀',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
