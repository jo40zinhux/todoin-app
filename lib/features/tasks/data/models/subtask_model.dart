import '../../domain/entities/subtask.dart';

class SubTaskModel {
  final String title;
  final bool done;

  const SubTaskModel({
    required this.title,
    this.done = false,
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

  SubTask toEntity() {
    return SubTask(
      title: title,
      done: done,
    );
  }
}
