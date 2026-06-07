class WeeklyStats {
  final int tasksCompleted;
  final int tasksStarted;
  final int xpEarned;

  const WeeklyStats({
    this.tasksCompleted = 0,
    this.tasksStarted = 0,
    this.xpEarned = 0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeeklyStats &&
          runtimeType == other.runtimeType &&
          tasksCompleted == other.tasksCompleted &&
          tasksStarted == other.tasksStarted &&
          xpEarned == other.xpEarned;

  @override
  int get hashCode => Object.hash(tasksCompleted, tasksStarted, xpEarned);
}
