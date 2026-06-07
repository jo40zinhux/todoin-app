import 'task.dart';

/// Resultado do carregamento local de tarefas.
class TasksLoadResult {
  final List<Task> tasks;
  final bool recoveredFromCorruption;

  const TasksLoadResult({
    required this.tasks,
    this.recoveredFromCorruption = false,
  });
}
