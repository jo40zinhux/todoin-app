import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/reminder_settings.dart';

class ReminderLocalDataSource {
  static const _key = 'reminder_settings';

  final SharedPreferences prefs;

  ReminderLocalDataSource(this.prefs);

  Future<ReminderSettings> load() async {
    final raw = prefs.getString(_key);
    if (raw == null) return const ReminderSettings();

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return ReminderSettings(
        enabled: map['enabled'] as bool? ?? false,
        hour: map['hour'] as int? ?? 9,
        minute: map['minute'] as int? ?? 0,
      );
    } catch (e) {
      debugPrint('[ReminderLocalDataSource] JSON corrompido: $e');
      await prefs.remove(_key);
      return const ReminderSettings();
    }
  }

  Future<void> save(ReminderSettings settings) async {
    await prefs.setString(
      _key,
      jsonEncode({
        'enabled': settings.enabled,
        'hour': settings.hour,
        'minute': settings.minute,
      }),
    );
  }
}
