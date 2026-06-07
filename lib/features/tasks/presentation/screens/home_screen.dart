import 'dart:async';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/animations/animation_constants.dart';
import '../../../../core/animations/xp_floating_label.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/feedback_service.dart';
import '../../../billing/domain/entities/entitlement.dart';
import '../../../billing/domain/usecases/should_show_paywall.dart';
import '../../../billing/presentation/providers/billing_provider.dart';
import '../../../billing/presentation/widgets/paywall_sheet.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../stats/presentation/providers/stats_provider.dart';
import '../../../stats/presentation/widgets/progress_sheet.dart';
import '../../domain/add_task_result.dart';
import '../../domain/entities/task.dart';
import '../controllers/home_screen_effects.dart';
import '../providers/tasks_provider.dart';
import '../widgets/add_task_sheet.dart';
import '../widgets/cant_start_sheet.dart';
import '../widgets/home_empty_state.dart';
import '../widgets/home_header.dart';
import '../widgets/home_info_banners.dart';
import '../widgets/home_loading_state.dart';
import '../widgets/pending_tasks_list.dart';
import '../widgets/task_card.dart';
import '../widgets/timer_launcher_sheet.dart';
import '../widgets/timer_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late HomeScreenEffects _effects;

  bool _isLoading = true;
  bool _showXpLabel = false;
  int _xpAnimBegin = 0;
  Key _xpAnimKey = const ValueKey(0);
  Timer? _cloudSyncDebounce;
  Timer? _widgetSyncDebounce;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: AppAnimations.slow);

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _effects = HomeScreenEffects(ref);
  }

  Future<void> _loadData() async {
    try {
      await _effects.loadInitialData(
        onCorruptionRecovered: () {
          if (mounted) _showDataRecoveryMessage();
        },
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showDataRecoveryMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Recuperamos seus dados com segurança. '
          'Se algo sumiu, use o backup Pro nas configurações.',
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 6),
      ),
    );
  }

  @override
  void dispose() {
    _cloudSyncDebounce?.cancel();
    _widgetSyncDebounce?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  void _scheduleCloudPush() {
    _cloudSyncDebounce?.cancel();
    _cloudSyncDebounce = Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      _effects.pushCloudSync();
    });
  }

  void _scheduleWidgetSync() {
    _widgetSyncDebounce?.cancel();
    _widgetSyncDebounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      _effects.syncWidget();
    });
  }

  void _onXpChanged(int? previous, int next) {
    if (previous == next) return;
    setState(() {
      _xpAnimBegin = (previous ?? next).clamp(0, next);
      _xpAnimKey = ValueKey(next);
    });
  }

  Future<void> _showPaywall(PaywallTrigger trigger) async {
    await PaywallSheet.show(
      context,
      trigger: trigger,
      onPurchase: (planId) =>
          ref.read(entitlementNotifierProvider.notifier).purchase(planId),
      onRestore: () => ref.read(entitlementNotifierProvider.notifier).restore(),
      onDismiss: () =>
          ref.read(entitlementNotifierProvider.notifier).dismissPaywall(),
    );
  }

  Future<void> _maybeShowPaywallAfterCompletion() async {
    final entitlement =
        ref.read(entitlementNotifierProvider).value ?? const Entitlement(isPro: false);
    final shouldShow = await ref.read(shouldShowPaywallProvider)(
      ShouldShowPaywallParams(entitlement: entitlement),
    );
    if (shouldShow && mounted) {
      await _showPaywall(PaywallTrigger.afterCompletions);
    }
  }

  void _showAddTaskSheet() {
    FeedbackService.click();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddTaskSheet(
        onAdd: (title, type, {subtasks}) async {
          final result = await ref
              .read(tasksNotifierProvider.notifier)
              .addTask(title, type, subtasks: subtasks);

          if (!mounted) return;

          switch (result) {
            case AddTaskResult.limitReached:
              await _showPaywall(PaywallTrigger.taskLimit);
            case AddTaskResult.persistFailed:
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Não foi possível salvar a tarefa. Tente novamente.',
                  ),
                ),
              );
            case AddTaskResult.success:
              AnalyticsService.instance.taskCreated();
              await ref.read(statsNotifierProvider.notifier).onTaskStarted();
              _scheduleCloudPush();
            case AddTaskResult.invalidTitle:
              break;
          }
        },
      ),
    );
  }

  Future<void> _openTimer() async {
    FeedbackService.click();
    final entitlement =
        ref.read(entitlementNotifierProvider).value ?? const Entitlement(isPro: false);
    final durations =
        await ref.read(getAvailableTimerDurationsProvider)(entitlement);
    final taskTitle =
        ref.read(tasksNotifierProvider.notifier).currentTask?.title ??
            'Foco ativo';

    if (durations.length == 1) {
      AnalyticsService.instance.timerStarted(seconds: durations.first);
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => TimerWidget(
          durationSeconds: durations.first,
          taskTitle: taskTitle,
        ),
      );
      return;
    }

    await TimerLauncherSheet.show(context, taskTitle: taskTitle);
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
    FeedbackService.xp();
    _confettiController.play();
    AnalyticsService.instance.taskCompleted();

    setState(() => _showXpLabel = true);
    Future.delayed(const Duration(milliseconds: 950), () {
      if (mounted) setState(() => _showXpLabel = false);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ref.read(tasksNotifierProvider.notifier).randomCelebration,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _onTaskCompleted() async {
    _celebrate();
    _scheduleCloudPush();
    await _maybeShowPaywallAfterCompletion();
  }

  void _showProgressSheet() {
    final stats = ref.read(statsNotifierProvider).value;
    final entitlement =
        ref.read(entitlementNotifierProvider).value ?? const Entitlement(isPro: false);
    if (stats == null) return;

    ProgressSheet.show(
      context,
      streak: stats.streak,
      weekly: stats.weekly,
      isPro: entitlement.isPro,
      onUpgrade: entitlement.isPro
          ? null
          : () => _showPaywall(PaywallTrigger.afterCompletions),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    ref.listen<int>(xpNotifierProvider, (previous, next) {
      _onXpChanged(previous, next);
      _scheduleCloudPush();
    });

    final xp = ref.watch(xpNotifierProvider);
    final tasks = ref.watch(tasksNotifierProvider);
    final tasksNotifier = ref.read(tasksNotifierProvider.notifier);
    final badDayMode =
        ref.watch(settingsNotifierProvider.select((s) => s.badDayMode));
    final isPro = ref.watch(
      entitlementNotifierProvider.select((a) => a.value?.isPro ?? false),
    );
    final streak = ref.watch(
      statsNotifierProvider.select((a) => a.value?.streak.currentStreak ?? 0),
    );

    final pendingLimit = badDayMode ? 1 : 3;

    ref.listen<List<Task>>(tasksNotifierProvider, (_, __) {
      _scheduleWidgetSync();
    });

    final current = tasksNotifier.currentTask;
    final pendingOps = tasksNotifier.pendingTasks(limit: pendingLimit);
    final upcomingTasks =
        pendingOps.length > 1 ? pendingOps.sublist(1) : const <Task>[];
    final allCompleted = tasks.isNotEmpty && current == null;
    final activeCount = tasks.where((t) => !t.completed).length;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: HomeHeader(
                    xp: xp,
                    xpAnimKey: _xpAnimKey,
                    xpAnimBegin: _xpAnimBegin,
                    streak: streak,
                    isPro: isPro,
                    onProgressTap: _showProgressSheet,
                  ),
                ),
                if (badDayMode)
                  const SliverToBoxAdapter(child: HomeBadDayBanner()),
                if (!isPro && activeCount > 0)
                  SliverToBoxAdapter(
                    child: HomeFreeTierBanner(activeCount: activeCount),
                  ),
                if (_isLoading)
                  const SliverFillRemaining(child: HomeLoadingState())
                else if (current == null)
                  SliverFillRemaining(
                    child: HomeEmptyState(
                      onAdd: _showAddTaskSheet,
                      allCompleted: allCompleted,
                    ),
                  )
                else ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                      child: Text(
                        '🎯 Sua tarefa agora',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: TaskCard(
                      key: ValueKey(current.id),
                      task: current,
                      timerButtonLabel: isPro
                          ? 'Escolher timer de foco'
                          : 'Começar por 2 minutos',
                      onToggleSubtask: (index) async {
                        final completed = await tasksNotifier.toggleSubtask(
                          current.id,
                          index,
                        );
                        if (!mounted) return;
                        if (completed) {
                          await _onTaskCompleted();
                        } else {
                          FeedbackService.subtaskDone();
                        }
                      },
                      onStartTimer: _openTimer,
                      onCantStart: () {
                        FeedbackService.click();
                        _showCantStartSheet(current.firstIncompleteSub?.title);
                      },
                      onComplete: () async {
                        final completed =
                            await tasksNotifier.completeTask(current.id);
                        if (completed && mounted) await _onTaskCompleted();
                      },
                    ),
                  ),
                  if (upcomingTasks.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                        child: Text(
                          'A seguir',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                    ),
                    PendingTasksList(
                      tasks: upcomingTasks,
                      onRemove: tasksNotifier.removeTask,
                    ),
                  ],
                ],
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
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
      floatingActionButton: _isLoading || current == null
          ? null
          : FloatingActionButton.extended(
              onPressed: _showAddTaskSheet,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Começar algo'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
    );
  }
}
