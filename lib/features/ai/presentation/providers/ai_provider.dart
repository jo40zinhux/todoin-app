import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/subtask_llm_datasource.dart';
import '../../data/repositories/subtask_ai_repository_impl.dart';
import '../../domain/repositories/subtask_ai_repository.dart';
import '../../domain/usecases/suggest_subtasks.dart';

final subtaskLlmDataSourceProvider = Provider<SubtaskLlmDataSource>((ref) {
  return SubtaskLlmDataSource();
});

final subtaskAiRepositoryProvider = Provider<SubtaskAiRepository>((ref) {
  return SubtaskAiRepositoryImpl(ref.watch(subtaskLlmDataSourceProvider));
});

final suggestSubtasksProvider = Provider<SuggestSubtasks>((ref) {
  return SuggestSubtasks(ref.watch(subtaskAiRepositoryProvider));
});
