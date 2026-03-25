import '../../domain/entities/subtask.dart';

class SubTaskModel extends SubTask {
  const SubTaskModel({
    required super.title,
    super.done = false,
  });

  factory SubTaskModel.fromJson(Map<String, dynamic> json) {
    return SubTaskModel(
      title: json['title'] as String,
      done: json['done'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'done': done,
    };
  }

  factory SubTaskModel.fromEntity(SubTask entity) {
    return SubTaskModel(
      title: entity.title,
      done: entity.done,
    );
  }
}
