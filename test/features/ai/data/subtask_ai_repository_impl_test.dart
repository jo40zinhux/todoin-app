import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todoin_focus_app/features/ai/data/datasources/subtask_llm_datasource.dart';
import 'package:todoin_focus_app/features/ai/data/repositories/subtask_ai_repository_impl.dart';
import 'package:todoin_focus_app/features/ai/domain/entities/subtask_suggestion_result.dart';
import 'package:todoin_focus_app/features/tasks/domain/entities/task.dart';

class MockSubtaskLlmDataSource extends Mock implements SubtaskLlmDataSource {}

void main() {
  late MockSubtaskLlmDataSource dataSource;
  late SubtaskAiRepositoryImpl repository;

  setUp(() {
    dataSource = MockSubtaskLlmDataSource();
    repository = SubtaskAiRepositoryImpl(dataSource);
  });

  test('uses LLM subtasks when API returns titles', () async {
    when(
      () => dataSource.suggestSubtaskTitles(
        taskTitle: any(named: 'taskTitle'),
        taskTypeLabel: any(named: 'taskTypeLabel'),
      ),
    ).thenAnswer((_) async => ['Passo 1', 'Passo 2', 'Passo 3']);

    final result = await repository.suggest('Estudar Flutter', TaskType.study);

    expect(result.subtasks, hasLength(3));
    expect(result.subtasks.first.title, 'Passo 1');
    expect(result.source, SubtaskSuggestionSource.llm);
  });

  test('falls back to heuristics when API returns null', () async {
    when(
      () => dataSource.suggestSubtaskTitles(
        taskTitle: any(named: 'taskTitle'),
        taskTypeLabel: any(named: 'taskTypeLabel'),
      ),
    ).thenAnswer((_) async => null);

    final result = await repository.suggest('Responder email', TaskType.action);

    expect(result.subtasks, isNotEmpty);
    expect(result.subtasks.first.title, contains('caixa de entrada'));
    expect(result.source, SubtaskSuggestionSource.heuristic);
  });
}
