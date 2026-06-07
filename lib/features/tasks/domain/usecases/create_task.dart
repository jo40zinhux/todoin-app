import 'package:uuid/uuid.dart';

import '../../../../core/validation/input_limits.dart';
import '../entities/subtask.dart';
import '../entities/task.dart';
import '../task_rules.dart';

class CreateTaskParams {
  final String title;
  final TaskType type;
  final String? id;
  final List<SubTask>? subtasksOverride;

  const CreateTaskParams({
    required this.title,
    required this.type,
    this.id,
    this.subtasksOverride,
  });
}

class CreateTask {
  Task? call(CreateTaskParams params) {
    final trimmed = params.title.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.length > InputLimits.maxTaskTitleLength) return null;

    return Task(
      id: params.id ?? const Uuid().v4(),
      title: InputLimits.normalizeTaskTitle(trimmed),
      subtasks: params.subtasksOverride ??
          generateSubtasks(trimmed, params.type),
      type: params.type,
    );
  }
}
