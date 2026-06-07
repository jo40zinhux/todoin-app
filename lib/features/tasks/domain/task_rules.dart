import 'entities/subtask.dart';
import 'entities/task.dart';

const int kXpPerTaskCompletion = 10;

TaskType detectTaskType(String text) {
  final lower = text.toLowerCase();

  if (lower.contains('estudar') || lower.contains('ler')) {
    return TaskType.study;
  }

  if (lower.contains('limpar') ||
      lower.contains('organizar') ||
      lower.contains('arrumar')) {
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
      return const [
        SubTask(title: 'Começar (primeiro passo pequeno)'),
        SubTask(title: 'Fazer a primeira parte'),
        SubTask(title: 'Revisar o que fez'),
      ];
  }
}
