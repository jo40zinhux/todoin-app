class StreakState {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActiveDate;

  const StreakState({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActiveDate,
  });

  StreakState copyWith({
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActiveDate,
  }) {
    return StreakState(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StreakState &&
          runtimeType == other.runtimeType &&
          currentStreak == other.currentStreak &&
          longestStreak == other.longestStreak &&
          lastActiveDate == other.lastActiveDate;

  @override
  int get hashCode => Object.hash(currentStreak, longestStreak, lastActiveDate);
}
