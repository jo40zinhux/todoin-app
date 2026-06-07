import 'package:flutter/foundation.dart';

/// Subtarefas inteligentes (Pro) — configure via --dart-define.
///
/// Produção: use [aiProxyUrl] (Edge Function). [openAiApiKey] só em debug local.
abstract class AiConfig {
  /// URL da Edge Function (ex: https://xxx.supabase.co/functions/v1/suggest-subtasks)
  static const aiProxyUrl = String.fromEnvironment(
    'AI_PROXY_URL',
    defaultValue: '',
  );

  /// Apenas dev local — não incluir em builds de release.
  static const openAiApiKey = String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: '',
  );

  static const openAiModel = String.fromEnvironment(
    'OPENAI_MODEL',
    defaultValue: 'gpt-4o-mini',
  );

  /// Necessário para chamar a Edge Function com JWT verification ativo.
  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  static bool get useProxy => aiProxyUrl.isNotEmpty;

  static bool get allowsDirectOpenAi => kDebugMode && openAiApiKey.isNotEmpty;

  static bool get isConfigured => useProxy || allowsDirectOpenAi;
}
