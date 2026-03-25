import '../../features/tasks/domain/entities/subtask.dart';
import '../../features/tasks/domain/entities/task.dart';

TaskType detectTaskType(String text) {
  final lower = text.toLowerCase();

  if (lower.contains('estudar') || lower.contains('ler')) {
    return TaskType.study;
  }

  if (lower.contains('limpar') || lower.contains('organizar') || lower.contains('arrumar')) {
    return TaskType.organizing;
  }

  if (lower.contains('fazer') || lower.contains('resolver')) {
    return TaskType.action;
  }

  return TaskType.general;
}

List<SubTask> generateSubtasks(String title, TaskType type) {
  switch (type) {
    case TaskType.study:
      return [
        SubTask(title: 'Abrir/preparar material de "$title"'),
        const SubTask(title: 'Estudar uma pequena parte'),
        const SubTask(title: 'Revisar o que aprendeu'),
      ];

    case TaskType.organizing:
      return const [
        SubTask(title: 'Escolher uma área pequena'),
        SubTask(title: 'Organizar apenas essa parte'),
        SubTask(title: 'Guardar ou descartar itens'),
      ];

    case TaskType.action:
      return const [
        SubTask(title: 'Dar o primeiro passo'),
        SubTask(title: 'Continuar por alguns minutos'),
        SubTask(title: 'Revisar progresso'),
      ];

    case TaskType.general:
    default:
      return const [
        SubTask(title: 'Começar (primeiro passo pequeno)'),
        SubTask(title: 'Fazer a primeira parte'),
        SubTask(title: 'Revisar o que fez'),
      ];
  }
}

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
