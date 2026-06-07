/// Sessão Supabase Auth para sync com RLS por usuário.
class SyncAuthSession {
  final String accessToken;
  final String userId;
  final String refreshToken;
  final DateTime expiresAt;

  const SyncAuthSession({
    required this.accessToken,
    required this.userId,
    required this.refreshToken,
    required this.expiresAt,
  });

  bool get isValid => DateTime.now().isBefore(expiresAt.subtract(const Duration(minutes: 1)));
}
