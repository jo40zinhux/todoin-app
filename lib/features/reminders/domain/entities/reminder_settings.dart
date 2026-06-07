class ReminderSettings {
  final bool enabled;
  final int hour;
  final int minute;

  const ReminderSettings({
    this.enabled = false,
    this.hour = 9,
    this.minute = 0,
  });

  ReminderSettings copyWith({
    bool? enabled,
    int? hour,
    int? minute,
  }) {
    return ReminderSettings(
      enabled: enabled ?? this.enabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderSettings &&
          runtimeType == other.runtimeType &&
          enabled == other.enabled &&
          hour == other.hour &&
          minute == other.minute;

  @override
  int get hashCode => Object.hash(enabled, hour, minute);
}
