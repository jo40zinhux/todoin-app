import '../../domain/entities/task.dart';
import 'subtask_model.dart';

class TaskModel {
  final String id;
  final String title;
  final bool completed;
  final List<SubTaskModel> subtasks;
  final TaskType type;

  const TaskModel({
    required this.id,
    required this.title,
    this.completed = false,
    required this.subtasks,
    this.type = TaskType.general,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      completed: json['completed'] as bool? ?? false,
      subtasks: (json['subtasks'] as List<dynamic>?)
              ?.map((s) => SubTaskModel.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      type: TaskType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TaskType.general,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'completed': completed,
      'subtasks': subtasks.map((s) => s.toJson()).toList(),
      'type': type.name,
    };
  }

  factory TaskModel.fromEntity(Task entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      completed: entity.completed,
      subtasks: entity.subtasks
          .map((s) => SubTaskModel.fromEntity(s))
          .toList(),
      type: entity.type,
    );
  }

  Task toEntity() {
    return Task(
      id: id,
      title: title,
      completed: completed,
      subtasks: subtasks.map((s) => s.toEntity()).toList(),
      type: type,
    );
  }
}
