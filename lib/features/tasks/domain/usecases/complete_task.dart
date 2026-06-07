import '../entities/task.dart';
import '../task_rules.dart';

class CompleteTaskParams {
  final Task task;

  const CompleteTaskParams({required this.task});
}

class CompleteTaskResult {
  final Task updatedTask;
  final int xpEarned;

  const CompleteTaskResult({
    required this.updatedTask,
    required this.xpEarned,
  });
}

class CompleteTask {
  CompleteTaskResult? call(CompleteTaskParams params) {
    final task = params.task;
    if (task.completed) return null;

    final completedSubtasks =
        task.subtasks.map((s) => s.copyWith(done: true)).toList();

    return CompleteTaskResult(
      updatedTask: task.copyWith(
        completed: true,
        subtasks: completedSubtasks,
      ),
      xpEarned: kXpPerTaskCompletion,
    );
  }
}
