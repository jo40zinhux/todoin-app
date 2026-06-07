import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/config/sync_config.dart';
import '../../domain/entities/sync_auth_session.dart';

class RemoteSyncRecord {
  final Map<String, dynamic> payload;
  final DateTime updatedAt;

  const RemoteSyncRecord({
    required this.payload,
    required this.updatedAt,
  });
}

class SyncRemoteDataSource {
  Future<void> upsert({
    required String deviceId,
    required Map<String, dynamic> payload,
    required DateTime updatedAt,
    required SyncAuthSession session,
  }) async {
    _requireValidSession(session);

    final response = await http
        .post(
          _tableUri(SyncConfig.syncTableV2),
          headers: _authHeaders(session.accessToken),
          body: jsonEncode([
            {
              'user_id': session.userId,
              'device_id': deviceId,
              'payload': payload,
              'updated_at': updatedAt.toUtc().toIso8601String(),
            },
          ]),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw SyncRemoteException(
        'Falha ao enviar dados (${response.statusCode}).',
      );
    }
  }

  Future<RemoteSyncRecord?> fetch({
    required String deviceId,
    required SyncAuthSession session,
  }) async {
    _requireValidSession(session);

    final uri = _tableUri(SyncConfig.syncTableV2).replace(
      queryParameters: {
        'user_id': 'eq.${session.userId}',
        'device_id': 'eq.$deviceId',
        'select': 'payload,updated_at',
        'limit': '1',
      },
    );

    final response = await http
        .get(uri, headers: _authHeaders(session.accessToken))
        .timeout(const Duration(seconds: 30));

    return _parseFetchResponse(response);
  }

  void _requireValidSession(SyncAuthSession session) {
    if (!session.isValid) {
      throw const SyncRemoteException(
        'Sessão de sincronização inválida ou expirada.',
      );
    }
  }

  RemoteSyncRecord? _parseFetchResponse(http.Response response) {
    if (response.statusCode == 404) return null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw SyncRemoteException(
        'Falha ao buscar dados (${response.statusCode}).',
      );
    }

    final list = jsonDecode(response.body) as List<dynamic>;
    if (list.isEmpty) return null;

    final row = list.first as Map<String, dynamic>;
    final payloadRaw = row['payload'];
    if (payloadRaw is! Map) {
      throw const SyncRemoteException('Payload remoto inválido.');
    }

    final payload = Map<String, dynamic>.from(payloadRaw);
    final updatedAt = DateTime.parse(row['updated_at'] as String);

    return RemoteSyncRecord(payload: payload, updatedAt: updatedAt);
  }

  Uri _tableUri(String table) =>
      Uri.parse('${SyncConfig.supabaseUrl}/rest/v1/$table');

  Map<String, String> _authHeaders(String accessToken) => {
        'apikey': SyncConfig.supabaseAnonKey,
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
        'Prefer': 'resolution=merge-duplicates,return=minimal',
        'Accept': 'application/json',
      };
}

class SyncRemoteException implements Exception {
  final String message;
  const SyncRemoteException(this.message);

  @override
  String toString() => message;
}
