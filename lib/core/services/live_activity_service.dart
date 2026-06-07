import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:live_activities/live_activities.dart';

/// Serviço que encapsula a integração com Live Activities / Dynamic Island (iOS 16.1+).
///
/// No Android, o equivalente (foreground notification) é gerenciado pelo
/// [ForegroundService]. Este serviço é no-op em plataformas não-iOS.
class LiveActivityService {
  LiveActivityService._internal();

  static final LiveActivityService instance = LiveActivityService._internal();

  final _plugin = LiveActivities();
  String? _currentActivityId;
  bool _supported = false;

  // ───────────────────────────────────────────────
  // Inicialização
  // ───────────────────────────────────────────────

  /// Inicializa o plugin e verifica suporte da plataforma.
  /// Deve ser chamado antes de qualquer outra operação.
  Future<void> initialize() async {
    if (!Platform.isIOS) return;

    try {
      // O appGroupId deve corresponder ao App Group configurado no Xcode
      // Ex: group.com.yourcompany.todoin
      await _plugin.init(appGroupId: 'group.com.cubitapp.todoinapp');
      _supported = true;
      debugPrint(
          '[LiveActivityService] Live Activities suportado e inicializado.');
    } catch (e) {
      _supported = false;
      debugPrint('[LiveActivityService] Live Activities não disponível: $e');
    }
  }

  // ───────────────────────────────────────────────
  // Controle do Timer
  // ───────────────────────────────────────────────

  /// Inicia uma Live Activity para o timer de [totalSeconds] segundos.
  Future<void> startTimerActivity({
    required int totalSeconds,
    String taskTitle = 'Foco ativo',
  }) async {
    if (!Platform.isIOS || !_supported) return;

    try {
      final endTime = DateTime.now()
          .add(Duration(seconds: totalSeconds))
          .millisecondsSinceEpoch;

      final activityId = await _plugin.createActivity({
        'timerEndMillis': endTime.toDouble(),
        'taskTitle': taskTitle,
        'remainingSeconds': totalSeconds,
        'isCompleted': false,
      });
      _currentActivityId = activityId;
      debugPrint('[LiveActivityService] Activity iniciada: $activityId');
    } catch (e) {
      debugPrint('[LiveActivityService] Erro ao iniciar activity: $e');
    }
  }

  /// Atualiza a contagem restante na Live Activity.
  Future<void> updateTimerActivity({required int remainingSeconds}) async {
    if (!Platform.isIOS || !_supported || _currentActivityId == null) return;

    try {
      await _plugin.updateActivity(
        _currentActivityId!,
        {
          'remainingSeconds': remainingSeconds,
          'isCompleted': false,
        },
      );
    } catch (e) {
      debugPrint('[LiveActivityService] Erro ao atualizar activity: $e');
    }
  }

  /// Encerra a Live Activity marcando como concluída.
  Future<void> endTimerActivity({bool completed = false}) async {
    if (!Platform.isIOS || !_supported || _currentActivityId == null) return;

    try {
      await _plugin.endActivity(_currentActivityId!);
      _currentActivityId = null;
      debugPrint(
          '[LiveActivityService] Activity encerrada (completed: $completed).');
    } catch (e) {
      debugPrint('[LiveActivityService] Erro ao encerrar activity: $e');
    }
  }

  /// Encerra todas as Live Activities ativas.
  Future<void> endAll() async {
    if (!Platform.isIOS || !_supported) return;
    try {
      await _plugin.endAllActivities();
      _currentActivityId = null;
    } catch (e) {
      debugPrint(
          '[LiveActivityService] Erro ao encerrar todas as activities: $e');
    }
  }

  bool get isSupported => _supported;
}
