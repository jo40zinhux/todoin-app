import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../features/sync/data/datasources/sync_auth_local_datasource.dart';
import '../../features/sync/domain/entities/sync_auth_session.dart';
import '../../features/sync/domain/gateways/sync_auth_gateway.dart';
import '../config/sync_config.dart';

/// Autenticação anônima Supabase para cloud sync com RLS (app_sync_v2).
class SupabaseAuthService implements SyncAuthGateway {
  SupabaseAuthService._();
  static final SupabaseAuthService instance = SupabaseAuthService._();

  SyncAuthLocalDataSource? _local;

  void configure(SyncAuthLocalDataSource local) {
    _local = local;
  }

  Future<SyncAuthSession?> ensureSession() async {
    if (!SyncConfig.isConfigured || _local == null) return null;

    final stored = _local!.load();
    if (stored != null && stored.isValid) return stored;

    if (stored != null) {
      final refreshed = await _refresh(stored.refreshToken);
      if (refreshed != null) {
        await _local!.save(refreshed);
        return refreshed;
      }
    }

    final signedIn = await _signInAnonymously();
    if (signedIn != null) {
      await _local!.save(signedIn);
    }
    return signedIn;
  }

  Future<SyncAuthSession?> _signInAnonymously() async {
    try {
      final response = await http
          .post(
            Uri.parse('${SyncConfig.supabaseUrl}/auth/v1/signup'),
            headers: _anonHeaders,
            body: jsonEncode({}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint(
          '[SupabaseAuthService] Anonymous signup failed: ${response.statusCode}',
        );
        return null;
      }

      return _sessionFromBody(jsonDecode(response.body) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('[SupabaseAuthService] signInAnonymously: $e');
      return null;
    }
  }

  Future<SyncAuthSession?> _refresh(String refreshToken) async {
    try {
      final response = await http
          .post(
            Uri.parse(
              '${SyncConfig.supabaseUrl}/auth/v1/token?grant_type=refresh_token',
            ),
            headers: _anonHeaders,
            body: jsonEncode({'refresh_token': refreshToken}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }

      return _sessionFromBody(jsonDecode(response.body) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('[SupabaseAuthService] refresh: $e');
      return null;
    }
  }

  SyncAuthSession? _sessionFromBody(Map<String, dynamic> body) {
    final access = body['access_token'] as String?;
    final refresh = body['refresh_token'] as String?;
    final expiresIn = body['expires_in'] as int? ?? 3600;
    final user = body['user'] as Map<String, dynamic>?;
    final userId = user?['id'] as String?;

    if (access == null || refresh == null || userId == null) return null;

    return SyncAuthSession(
      accessToken: access,
      userId: userId,
      refreshToken: refresh,
      expiresAt: DateTime.now().add(Duration(seconds: expiresIn)),
    );
  }

  Map<String, String> get _anonHeaders => {
        'apikey': SyncConfig.supabaseAnonKey,
        'Authorization': 'Bearer ${SyncConfig.supabaseAnonKey}',
        'Content-Type': 'application/json',
      };
}
