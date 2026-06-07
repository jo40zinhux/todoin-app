import '../../../../core/usecases/usecase.dart';
import '../../../tasks/domain/entities/task.dart';
import '../entities/subtask_suggestion_result.dart';
import '../repositories/subtask_ai_repository.dart';

class SuggestSubtasksParams {
  final String title;
  final TaskType type;

  const SuggestSubtasksParams({required this.title, required this.type});
}

class SuggestSubtasks
    implements UseCase<SubtaskSuggestionResult, SuggestSubtasksParams> {
  final SubtaskAiRepository repository;

  SuggestSubtasks(this.repository);

  @override
  Future<SubtaskSuggestionResult> call(SuggestSubtasksParams params) =>
      repository.suggest(params.title, params.type);
}
