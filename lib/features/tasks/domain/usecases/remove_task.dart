import '../entities/task.dart';

class RemoveTaskParams {
  final List<Task> tasks;
  final String taskId;

  const RemoveTaskParams({
    required this.tasks,
    required this.taskId,
  });
}

class RemoveTaskResult {
  final List<Task> updatedTasks;
  final bool removed;

  const RemoveTaskResult({
    required this.updatedTasks,
    required this.removed,
  });
}

class RemoveTask {
  RemoveTaskResult call(RemoveTaskParams params) {
    final updatedTasks =
        params.tasks.where((task) => task.id != params.taskId).toList();

    return RemoveTaskResult(
      updatedTasks: updatedTasks,
      removed: updatedTasks.length != params.tasks.length,
    );
  }
}
