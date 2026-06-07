import '../../../tasks/domain/entities/subtask.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../domain/entities/subtask_suggestion_result.dart';
import '../../domain/repositories/subtask_ai_repository.dart';
import '../../domain/subtask_suggestions.dart';
import '../datasources/subtask_llm_datasource.dart';

class SubtaskAiRepositoryImpl implements SubtaskAiRepository {
  final SubtaskLlmDataSource llm;

  SubtaskAiRepositoryImpl(this.llm);

  @override
  Future<SubtaskSuggestionResult> suggest(String title, TaskType type) async {
    final llmTitles = await llm.suggestSubtaskTitles(
      taskTitle: title,
      taskTypeLabel: type.name,
    );

    if (llmTitles != null && llmTitles.isNotEmpty) {
      return SubtaskSuggestionResult(
        subtasks: llmTitles.map((t) => SubTask(title: t)).toList(),
        source: SubtaskSuggestionSource.llm,
      );
    }

    return SubtaskSuggestionResult(
      subtasks: suggestPersonalizedSubtasks(title, type),
      source: SubtaskSuggestionSource.heuristic,
    );
  }
}
