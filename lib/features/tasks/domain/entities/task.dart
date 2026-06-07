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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Task &&
        other.id == id &&
        other.title == title &&
        other.completed == completed &&
        _listEquals(other.subtasks, subtasks) &&
        other.type == type;
  }

  @override
  int get hashCode => Object.hash(
        id,
        title,
        completed,
        Object.hashAll(subtasks),
        type,
      );
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
