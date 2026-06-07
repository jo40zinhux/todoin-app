import 'package:flutter_test/flutter_test.dart';
import 'package:todoin_focus_app/features/stats/domain/entities/streak_state.dart';
import 'package:todoin_focus_app/features/stats/domain/streak_rules.dart';

void main() {
  test('first activity starts streak at 1', () {
    const current = StreakState();
    final updated = updateGentleStreak(current, DateTime(2026, 6, 7));

    expect(updated.currentStreak, 1);
    expect(updated.longestStreak, 1);
  });

  test('consecutive day increments streak', () {
    final current = StreakState(
      currentStreak: 2,
      longestStreak: 2,
      lastActiveDate: DateTime(2026, 6, 6),
    );

    final updated = updateGentleStreak(current, DateTime(2026, 6, 7));

    expect(updated.currentStreak, 3);
    expect(updated.longestStreak, 3);
  });

  test('gap greater than one day resets to 1 gently', () {
    final current = StreakState(
      currentStreak: 5,
      longestStreak: 5,
      lastActiveDate: DateTime(2026, 6, 1),
    );

    final updated = updateGentleStreak(current, DateTime(2026, 6, 7));

    expect(updated.currentStreak, 1);
    expect(updated.longestStreak, 5);
  });

  test('same day activity does not change streak', () {
    final current = StreakState(
      currentStreak: 3,
      longestStreak: 3,
      lastActiveDate: DateTime(2026, 6, 7),
    );

    final updated = updateGentleStreak(current, DateTime(2026, 6, 7, 18));

    expect(updated.currentStreak, 3);
    expect(updated.longestStreak, 3);
  });
}
