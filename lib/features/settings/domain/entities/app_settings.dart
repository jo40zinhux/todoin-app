class AppSettings {
  final bool soundEnabled;
  final bool hapticEnabled;
  final bool badDayMode;

  const AppSettings({
    this.soundEnabled = true,
    this.hapticEnabled = true,
    this.badDayMode = false,
  });

  AppSettings copyWith({
    bool? soundEnabled,
    bool? hapticEnabled,
    bool? badDayMode,
  }) {
    return AppSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
      badDayMode: badDayMode ?? this.badDayMode,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AppSettings &&
        other.soundEnabled == soundEnabled &&
        other.hapticEnabled == hapticEnabled &&
        other.badDayMode == badDayMode;
  }

  @override
  int get hashCode => Object.hash(soundEnabled, hapticEnabled, badDayMode);
}
