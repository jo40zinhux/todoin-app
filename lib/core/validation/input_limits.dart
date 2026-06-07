/// Limites de validação para conteúdo criado pelo usuário.
class InputLimits {
  InputLimits._();

  static const int maxTaskTitleLength = 200;

  /// Normaliza título para persistência e prompts de IA.
  static String normalizeTaskTitle(String raw) {
    final trimmed = raw.trim();
    if (trimmed.length <= maxTaskTitleLength) return trimmed;
    return trimmed.substring(0, maxTaskTitleLength);
  }

  /// Escapa aspas para reduzir prompt injection em LLM.
  static String sanitizeForPrompt(String text) {
    return text.replaceAll('"', "'").replaceAll('\n', ' ');
  }
}
