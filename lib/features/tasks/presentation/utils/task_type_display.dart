import '../../domain/entities/task.dart';

String taskTypeName(TaskType type) {
  switch (type) {
    case TaskType.study:
      return 'Estudo';
    case TaskType.organizing:
      return 'Organização';
    case TaskType.action:
      return 'Ação';
    case TaskType.general:
      return 'Geral';
  }
}

String taskTypeIcon(TaskType type) {
  switch (type) {
    case TaskType.study:
      return '📚';
    case TaskType.organizing:
      return '🧹';
    case TaskType.action:
      return '⚡';
    case TaskType.general:
      return '🎯';
  }
}
