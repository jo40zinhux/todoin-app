import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class SyncLocalDataSource {
  static const _deviceIdKey = 'todoin_sync_device_id';
  static const _enabledKey = 'todoin_cloud_sync_enabled';
  static const _lastSyncedAtKey = 'todoin_last_synced_at';

  final SharedPreferences prefs;

  SyncLocalDataSource(this.prefs);

  Future<String> getOrCreateDeviceId() async {
    final existing = prefs.getString(_deviceIdKey);
    if (existing != null && existing.isNotEmpty) return existing;

    final id = const Uuid().v4();
    await prefs.setString(_deviceIdKey, id);
    return id;
  }

  bool get isEnabled => prefs.getBool(_enabledKey) ?? false;

  Future<void> setEnabled(bool value) => prefs.setBool(_enabledKey, value);

  DateTime? get lastSyncedAt {
    final raw = prefs.getString(_lastSyncedAtKey);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> setLastSyncedAt(DateTime value) =>
      prefs.setString(_lastSyncedAtKey, value.toUtc().toIso8601String());
}
