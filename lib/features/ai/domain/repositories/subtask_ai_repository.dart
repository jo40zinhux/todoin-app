import '../entities/subtask_suggestion_result.dart';
import '../../../tasks/domain/entities/task.dart';

abstract class SubtaskAiRepository {
  Future<SubtaskSuggestionResult> suggest(String title, TaskType type);
}
