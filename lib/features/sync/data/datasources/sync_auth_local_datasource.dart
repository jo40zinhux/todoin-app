import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/sync_auth_session.dart';

class SyncAuthLocalDataSource {
  static const _sessionKey = 'sync_auth_session';

  final SharedPreferences prefs;

  SyncAuthLocalDataSource(this.prefs);

  SyncAuthSession? load() {
    final raw = prefs.getString(_sessionKey);
    if (raw == null) return null;

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return SyncAuthSession(
        accessToken: map['accessToken'] as String,
        userId: map['userId'] as String,
        refreshToken: map['refreshToken'] as String,
        expiresAt: DateTime.parse(map['expiresAt'] as String),
      );
    } catch (e) {
      debugPrint('[SyncAuthLocalDataSource] Sessão corrompida, limpando: $e');
      prefs.remove(_sessionKey);
      return null;
    }
  }

  Future<void> save(SyncAuthSession session) async {
    await prefs.setString(
      _sessionKey,
      jsonEncode({
        'accessToken': session.accessToken,
        'userId': session.userId,
        'refreshToken': session.refreshToken,
        'expiresAt': session.expiresAt.toIso8601String(),
      }),
    );
  }

  Future<void> clear() => prefs.remove(_sessionKey);
}
