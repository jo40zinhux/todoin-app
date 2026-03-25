import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/subtask.dart';
import '../../domain/entities/task.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/save_tasks.dart';
import '../../domain/usecases/get_xp.dart';
import '../../domain/usecases/save_xp.dart';
import '../../../../core/utils/task_type_helper.dart';
import '../../data/datasources/task_local_datasource.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../../../core/services/feedback_service.dart';

// ---------- DI Providers ----------
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

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

// ---------- XP StateNotifier ----------
class XpNotifier extends StateNotifier<int> {
  final SaveXp _saveXp;

  XpNotifier(super.initialXp, this._saveXp);

  void setXp(int newXp) {
    state = newXp;
  }

  void addXp(int amount) {
    state += amount;
    _saveXp(state);
  }
}

final xpNotifierProvider = StateNotifierProvider<XpNotifier, int>((ref) {
  return XpNotifier(
      0, ref.watch(saveXpProvider)); // Initialized to 0, will be overwritten
});

// ---------- Tasks StateNotifier ----------
class TasksNotifier extends StateNotifier<List<Task>> {
  final SaveTasks _saveTasks;
  final Ref _ref;

  TasksNotifier(super.initialTasks, this._saveTasks, this._ref);

  void setAll(List<Task> tasks) {
    state = tasks;
  }

  List<Task> get pendingTasks =>
      state.where((t) => !t.completed).take(3).toList();

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

  Future<void> _persist(List<Task> newState) async {
    state = newState;
    await _saveTasks(newState);
  }

  Future<void> addTask(String title, TaskType type) async {
    if (title.trim().isEmpty) return;

    final subtasks = generateSubtasks(title.trim(), type);

    final newTask = Task(
      id: const Uuid().v4(),
      title: title.trim(),
      subtasks: subtasks,
      type: type,
    );

    await _persist([...state, newTask]);
  }

  Future<bool> toggleSubtask(String taskId, int subtaskIndex) async {
    final taskIndex = state.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return false;

    final task = state[taskIndex];
    final subtasks = List<SubTask>.from(task.subtasks);

    // Toggle subtask
    subtasks[subtaskIndex] =
        subtasks[subtaskIndex].copyWith(done: !subtasks[subtaskIndex].done);

    var updatedTask = task.copyWith(subtasks: subtasks);
    bool taskCompleted = false;

    if (updatedTask.allSubtasksDone && !updatedTask.completed) {
      updatedTask = updatedTask.copyWith(completed: true);
      _ref.read(xpNotifierProvider.notifier).addXp(10);
      FeedbackService.xp();
      taskCompleted = true;
    }

    final newState = List<Task>.from(state);
    newState[taskIndex] = updatedTask;
    await _persist(newState);

    return taskCompleted;
  }

  Future<void> completeTask(String taskId) async {
    final taskIndex = state.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return;

    final task = state[taskIndex];
    if (!task.completed) {
      final completedSubtasks =
          task.subtasks.map((s) => s.copyWith(done: true)).toList();
      final updatedTask =
          task.copyWith(completed: true, subtasks: completedSubtasks);

      _ref.read(xpNotifierProvider.notifier).addXp(10);
      FeedbackService.xp();

      final newState = List<Task>.from(state);
      newState[taskIndex] = updatedTask;
      await _persist(newState);
    }
  }

  Future<void> removeTask(String taskId) async {
    final newState = state.where((t) => t.id != taskId).toList();
    await _persist(newState);
  }
}

final tasksNotifierProvider =
    StateNotifierProvider<TasksNotifier, List<Task>>((ref) {
  return TasksNotifier([], ref.watch(saveTasksProvider), ref);
});
