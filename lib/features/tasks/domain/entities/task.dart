import 'subtask.dart';

enum TaskType {
  study,
  action,
  organizing,
  general,
}

class Task {
  final String id;
  final String title;
  final bool completed;
  final List<SubTask> subtasks;
  final TaskType type;

  const Task({
    required this.id,
    required this.title,
    this.completed = false,
    required this.subtasks,
    this.type = TaskType.general,
  });

  bool get allSubtasksDone =>
      subtasks.isNotEmpty && subtasks.every((s) => s.done);

  SubTask? get firstIncompleteSub =>
      subtasks.cast<SubTask?>().firstWhere((s) => !s!.done, orElse: () => null);

  Task copyWith({
    String? id,
    String? title,
    bool? completed,
    List<SubTask>? subtasks,
    TaskType? type,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      subtasks: subtasks ?? this.subtasks,
      type: type ?? this.type,
    );
  }
}
