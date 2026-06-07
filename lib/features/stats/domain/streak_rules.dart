import 'entities/streak_state.dart';

/// Atualiza streak de forma gentil: sem punição severa por dias perdidos.
StreakState updateGentleStreak(StreakState current, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);

  if (current.lastActiveDate == null) {
    return current.copyWith(
      currentStreak: 1,
      longestStreak: 1,
      lastActiveDate: today,
    );
  }

  final last = DateTime(
    current.lastActiveDate!.year,
    current.lastActiveDate!.month,
    current.lastActiveDate!.day,
  );

  if (last == today) {
    return current;
  }

  final gapDays = today.difference(last).inDays;

  int newStreak;
  if (gapDays == 1) {
    newStreak = current.currentStreak + 1;
  } else {
    // Reinicia em 1 (não em 0) — celebra o retorno
    newStreak = 1;
  }

  final newLongest =
      newStreak > current.longestStreak ? newStreak : current.longestStreak;

  return current.copyWith(
    currentStreak: newStreak,
    longestStreak: newLongest,
    lastActiveDate: today,
  );
}
