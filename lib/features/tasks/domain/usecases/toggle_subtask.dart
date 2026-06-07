import '../entities/subtask.dart';
import '../entities/task.dart';
import '../task_rules.dart';

class ToggleSubtaskParams {
  final Task task;
  final int subtaskIndex;

  const ToggleSubtaskParams({
    required this.task,
    required this.subtaskIndex,
  });
}

class ToggleSubtaskResult {
  final Task updatedTask;
  final bool taskCompleted;
  final int xpEarned;

  const ToggleSubtaskResult({
    required this.updatedTask,
    required this.taskCompleted,
    required this.xpEarned,
  });
}

class ToggleSubtask {
  ToggleSubtaskResult? call(ToggleSubtaskParams params) {
    final task = params.task;
    if (params.subtaskIndex < 0 || params.subtaskIndex >= task.subtasks.length) {
      return null;
    }

    final subtasks = List<SubTask>.from(task.subtasks);
    final index = params.subtaskIndex;
    subtasks[index] =
        subtasks[index].copyWith(done: !subtasks[index].done);

    var updatedTask = task.copyWith(subtasks: subtasks);
    var taskCompleted = false;
    var xpEarned = 0;

    if (updatedTask.allSubtasksDone && !updatedTask.completed) {
      updatedTask = updatedTask.copyWith(completed: true);
      taskCompleted = true;
      xpEarned = kXpPerTaskCompletion;
    }

    return ToggleSubtaskResult(
      updatedTask: updatedTask,
      taskCompleted: taskCompleted,
      xpEarned: xpEarned,
    );
  }
}
