/// Porta de domínio para agendar/cancelar lembretes gentis.
abstract class ReminderScheduler {
  Future<void> cancelAll();

  Future<void> schedule({
    required int hour,
    required int minute,
    required String message,
  });
}
