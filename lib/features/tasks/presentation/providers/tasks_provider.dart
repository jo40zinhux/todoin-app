import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/shared_preferences_provider.dart';
import '../../../billing/domain/entities/entitlement.dart';
import '../../../billing/domain/usecases/can_add_task.dart';
import '../../../billing/presentation/providers/billing_provider.dart';
import '../../../stats/presentation/providers/stats_provider.dart';
import '../../data/datasources/task_local_datasource.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/add_task_result.dart';
import '../../domain/entities/subtask.dart';
import '../../domain/entities/task.dart';
import '../../domain/usecases/complete_task.dart';
import '../../domain/usecases/create_task.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/get_xp.dart';
import '../../domain/usecases/save_tasks.dart';
import '../../domain/usecases/save_xp.dart';
import '../../domain/usecases/remove_task.dart';
import '../../domain/usecases/toggle_subtask.dart';

// ---------- DI Providers ----------
final taskLocalDataSourceProvider = Provider<TaskLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return TaskLocalDataSourceImpl(sharedPreferences: prefs);
});

final taskRepositoryProvider = Provider<TaskRepositoryImpl>((ref) {
  final localDataSource = ref.watch(taskLocalDataSourceProvider);
  return TaskRepositoryImpl(localDataSource: localDataSource);
});

final getTasksProvider = Provider<GetTasks>((ref) {
  return GetTasks(ref.watch(taskRepositoryProvider));
});

final saveTasksProvider = Provider<SaveTasks>((ref) {
  return SaveTasks(ref.watch(taskRepositoryProvider));
});

final getXpProvider = Provider<GetXp>((ref) {
  return GetXp(ref.watch(taskRepositoryProvider));
});

final saveXpProvider = Provider<SaveXp>((ref) {
  return SaveXp(ref.watch(taskRepositoryProvider));
});

final createTaskProvider = Provider<CreateTask>((ref) => CreateTask());

final toggleSubtaskProvider = Provider<ToggleSubtask>((ref) => ToggleSubtask());

final completeTaskProvider = Provider<CompleteTask>((ref) => CompleteTask());

final removeTaskProvider = Provider<RemoveTask>((ref) => RemoveTask());

// ---------- XP StateNotifier ----------
class XpNotifier extends StateNotifier<int> {
  final SaveXp _saveXp;

  XpNotifier(super.initialXp, this._saveXp);

  void setXp(int newXp) {
    state = newXp;
  }

  Future<void> addXp(int amount) async {
    state += amount;
    await _saveXp(state);
  }
}

final xpNotifierProvider = StateNotifierProvider<XpNotifier, int>((ref) {
  return XpNotifier(0, ref.watch(saveXpProvider));
});

// ---------- Tasks StateNotifier ----------
typedef XpEarnedCallback = Future<void> Function(int amount);
typedef TaskCompletedCallback = Future<void> Function(int xpEarned);

class TasksNotifier extends StateNotifier<List<Task>> {
  final SaveTasks _saveTasks;
  final CreateTask _createTask;
  final ToggleSubtask _toggleSubtask;
  final CompleteTask _completeTask;
  final RemoveTask _removeTask;
  final CanAddTask _canAddTask;
  final Future<Entitlement> Function() _getEntitlement;
  final XpEarnedCallback _onXpEarned;
  final TaskCompletedCallback _onTaskCompleted;

  TasksNotifier(
    super.initialTasks,
    this._saveTasks,
    this._createTask,
    this._toggleSubtask,
    this._completeTask,
    this._removeTask,
    this._canAddTask,
    this._getEntitlement,
    this._onXpEarned,
    this._onTaskCompleted,
  );

  void setAll(List<Task> tasks) {
    state = tasks;
  }

  List<Task> pendingTasks({int limit = 3}) =>
      state.where((t) => !t.completed).take(limit).toList();

  Task? get currentTask =>
      state.cast<Task?>().firstWhere((t) => !t!.completed, orElse: () => null);

  String get randomCelebration {
    final messages = [
      'Você começou. Isso já é progresso 🎉',
      'Pequenos passos contam. Continue! 💪',
      'Boa! Continue assim 🌟',
      'Mais uma conquista. Você está no caminho! 🚀',
      'Perfeito! Cada passo é uma vitória 🏆',
      'Mandou bem. Sigo com você! ⭐',
    ];
    return (messages..shuffle()).first;
  }

  Future<bool> _persist(List<Task> newState) async {
    final previous = state;
    state = newState;
    try {
      await _saveTasks(newState);
      return true;
    } catch (e, st) {
      state = previous;
      debugPrint('[TasksNotifier] Falha ao salvar tarefas: $e');
      assert(() {
        debugPrint('$st');
        return true;
      }());
      return false;
    }
  }

  Future<AddTaskResult> addTask(
    String title,
    TaskType type, {
    List<SubTask>? subtasks,
  }) async {
    final newTask = _createTask(CreateTaskParams(
      title: title,
      type: type,
      subtasksOverride: subtasks,
    ));
    if (newTask == null) return AddTaskResult.invalidTitle;

    final entitlement = await _getEntitlement();
    final canAdd = await _canAddTask(CanAddTaskParams(
      tasks: state,
      entitlement: entitlement,
    ));
    if (!canAdd) return AddTaskResult.limitReached;

    final saved = await _persist([...state, newTask]);
    return saved ? AddTaskResult.success : AddTaskResult.persistFailed;
  }

  Future<bool> toggleSubtask(String taskId, int subtaskIndex) async {
    final taskIndex = state.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return false;

    final result = _toggleSubtask(ToggleSubtaskParams(
      task: state[taskIndex],
      subtaskIndex: subtaskIndex,
    ));
    if (result == null) return false;

    if (result.xpEarned > 0) {
      await _onXpEarned(result.xpEarned);
    }

    final newState = List<Task>.from(state);
    newState[taskIndex] = result.updatedTask;
    final saved = await _persist(newState);
    if (!saved) return false;

    if (result.taskCompleted) {
      await _onTaskCompleted(result.xpEarned);
    }

    return result.taskCompleted;
  }

  Future<bool> completeTask(String taskId) async {
    final taskIndex = state.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return false;

    final result = _completeTask(CompleteTaskParams(task: state[taskIndex]));
    if (result == null) return false;

    final newState = List<Task>.from(state);
    newState[taskIndex] = result.updatedTask;
    final saved = await _persist(newState);
    if (!saved) return false;

    await _onXpEarned(result.xpEarned);
    await _onTaskCompleted(result.xpEarned);
    return true;
  }

  Future<bool> removeTask(String taskId) async {
    final result = _removeTask(RemoveTaskParams(tasks: state, taskId: taskId));
    if (!result.removed) return false;
    return _persist(result.updatedTasks);
  }
}

final tasksNotifierProvider =
    StateNotifierProvider<TasksNotifier, List<Task>>((ref) {
  return TasksNotifier(
    [],
    ref.watch(saveTasksProvider),
    ref.watch(createTaskProvider),
    ref.watch(toggleSubtaskProvider),
    ref.watch(completeTaskProvider),
    ref.watch(removeTaskProvider),
    ref.watch(canAddTaskProvider),
    () async {
      final state = ref.read(entitlementNotifierProvider);
      return state.value ?? const Entitlement(isPro: false);
    },
    (amount) => ref.read(xpNotifierProvider.notifier).addXp(amount),
    (xpEarned) async {
      await ref.read(statsNotifierProvider.notifier).onTaskCompleted(
            xpEarned: xpEarned,
          );
      await ref.read(entitlementNotifierProvider.notifier).onTaskCompleted();
    },
  );
});
