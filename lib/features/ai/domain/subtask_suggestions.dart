import '../../tasks/domain/entities/subtask.dart';
import '../../tasks/domain/entities/task.dart';
import '../../tasks/domain/task_rules.dart';

/// Gera subtarefas personalizadas com análise local do título (Pro).
/// Não requer API externa — pronto para plugar LLM no futuro.
List<SubTask> suggestPersonalizedSubtasks(String title, TaskType type) {
  final base = generateSubtasks(title, type);
  final trimmed = title.trim();
  if (trimmed.isEmpty) return base;

  final lower = trimmed.toLowerCase();

  if (lower.contains('email') || lower.contains('e-mail')) {
    return [
      const SubTask(title: 'Abrir a caixa de entrada'),
      SubTask(title: 'Responder só o essencial de "$trimmed"'),
      const SubTask(title: 'Fechar o app e respirar'),
    ];
  }

  if (lower.contains('reunião') || lower.contains('meeting')) {
    return [
      const SubTask(title: 'Abrir agenda / link da reunião'),
      const SubTask(title: 'Preparar 1 ponto que precisa falar'),
      const SubTask(title: 'Entrar na call (pode ser 2 min atrasado, tudo bem)'),
    ];
  }

  if (lower.contains('exercício') ||
      lower.contains('academia') ||
      lower.contains('caminhar')) {
    return [
      const SubTask(title: 'Vestir roupa confortável'),
      const SubTask(title: '5 minutos de movimento leve'),
      const SubTask(title: 'Celebrar — você se moveu'),
    ];
  }

  if (lower.split(' ').length <= 3) {
    return [
      SubTask(title: 'Preparar o mínimo para "$trimmed"'),
      SubTask(title: 'Fazer a primeira parte de "$trimmed"'),
      const SubTask(title: 'Parar e reconhecer o progresso'),
    ];
  }

  return base;
}
