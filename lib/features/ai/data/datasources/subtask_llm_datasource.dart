import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../../core/config/ai_config.dart';
import '../../../../core/validation/input_limits.dart';

/// Datasource unificado: proxy (produção) ou OpenAI direto (debug).
class SubtaskLlmDataSource {
  Future<List<String>?> suggestSubtaskTitles({
    required String taskTitle,
    required String taskTypeLabel,
  }) async {
    if (!AiConfig.isConfigured) return null;

    final safeTitle = InputLimits.sanitizeForPrompt(
      InputLimits.normalizeTaskTitle(taskTitle),
    );
    if (safeTitle.isEmpty) return null;

    if (AiConfig.useProxy) {
      return _suggestViaProxy(safeTitle, taskTypeLabel);
    }

    if (AiConfig.allowsDirectOpenAi) {
      return _suggestViaOpenAiDirect(safeTitle, taskTypeLabel);
    }

    return null;
  }

  Future<List<String>?> _suggestViaProxy(
    String safeTitle,
    String taskTypeLabel,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse(AiConfig.aiProxyUrl),
            headers: _proxyHeaders,
            body: jsonEncode({
              'taskTitle': safeTitle,
              'taskType': taskTypeLabel,
            }),
          )
          .timeout(const Duration(seconds: 25));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint('[SubtaskLlmDataSource] Proxy HTTP ${response.statusCode}');
        return null;
      }

      final body = jsonDecode(response.body);
      if (body is! Map<String, dynamic>) return null;

      final list = body['subtasks'];
      if (list is! List || list.isEmpty) return null;

      return _parseSubtaskList(list);
    } catch (e, st) {
      debugPrint('[SubtaskLlmDataSource] Proxy error: $e');
      assert(() {
        debugPrint('$st');
        return true;
      }());
      return null;
    }
  }

  Future<List<String>?> _suggestViaOpenAiDirect(
    String safeTitle,
    String taskTypeLabel,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('https://api.openai.com/v1/chat/completions'),
            headers: {
              'Authorization': 'Bearer ${AiConfig.openAiApiKey}',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': AiConfig.openAiModel,
              'temperature': 0.4,
              'response_format': {'type': 'json_object'},
              'messages': [
                {
                  'role': 'system',
                  'content':
                      'Você ajuda pessoas com TDAH a dividir tarefas em 3 micro-passos '
                      'pequenos, concretos e sem julgamento. Responda APENAS JSON: '
                      '{"subtasks":["passo1","passo2","passo3"]}. Máximo 60 caracteres por passo.',
                },
                {
                  'role': 'user',
                  'content':
                      'Tarefa: "$safeTitle" (tipo: $taskTypeLabel). Gere 3 micro-passos em português.',
                },
              ],
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }

      final body = jsonDecode(response.body);
      if (body is! Map<String, dynamic>) return null;

      final choices = body['choices'];
      if (choices is! List || choices.isEmpty) return null;

      final first = choices.first;
      if (first is! Map) return null;

      final message = first['message'];
      if (message is! Map) return null;

      final content = message['content']?.toString() ?? '';
      if (content.isEmpty) return null;

      final parsed = jsonDecode(content);
      if (parsed is! Map<String, dynamic>) return null;

      final list = parsed['subtasks'];
      if (list is! List || list.isEmpty) return null;

      return _parseSubtaskList(list);
    } catch (e) {
      debugPrint('[SubtaskLlmDataSource] OpenAI direct error: $e');
      return null;
    }
  }

  Map<String, String> get _proxyHeaders {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (AiConfig.supabaseAnonKey.isNotEmpty) {
      headers['apikey'] = AiConfig.supabaseAnonKey;
      headers['Authorization'] = 'Bearer ${AiConfig.supabaseAnonKey}';
    }
    return headers;
  }

  List<String>? _parseSubtaskList(List list) {
    final titles = list
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .take(3)
        .toList();
    return titles.isEmpty ? null : titles;
  }
}
