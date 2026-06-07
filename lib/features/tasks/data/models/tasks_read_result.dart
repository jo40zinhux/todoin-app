import 'task_model.dart';

class TasksReadResult {
  final List<TaskModel> tasks;
  final bool recoveredFromCorruption;

  const TasksReadResult({
    required this.tasks,
    this.recoveredFromCorruption = false,
  });
}
