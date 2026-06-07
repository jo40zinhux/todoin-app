/// Limites do plano gratuito do toDoin.
abstract class FreeTierLimits {
  static const int maxActiveTasks = 5;
  static const int defaultTimerSeconds = 120;
  static const int paywallAfterCompletions = 3;
}

/// Durações de timer disponíveis no plano Pro (em segundos).
abstract class ProTimerDurations {
  static const List<int> seconds = [120, 300, 600, 900];

  static String label(int seconds) {
    switch (seconds) {
      case 120:
        return '2 min';
      case 300:
        return '5 min';
      case 600:
        return '10 min';
      case 900:
        return '15 min';
      default:
        return '${seconds ~/ 60} min';
    }
  }
}
