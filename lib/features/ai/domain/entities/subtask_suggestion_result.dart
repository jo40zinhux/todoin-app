import '../../../tasks/domain/entities/subtask.dart';

enum SubtaskSuggestionSource { llm, heuristic }

class SubtaskSuggestionResult {
  final List<SubTask> subtasks;
  final SubtaskSuggestionSource source;

  const SubtaskSuggestionResult({
    required this.subtasks,
    required this.source,
  });
}
