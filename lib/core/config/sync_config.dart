/// Supabase Cloud Sync — configure via --dart-define.
abstract class SyncConfig {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// Tabela com RLS por usuário autenticado (auth anônimo).
  static const syncTableV2 = 'app_sync_v2';

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
