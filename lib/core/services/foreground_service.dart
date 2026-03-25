import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

/// Serviço que gerencia o Foreground Service no Android durante o timer.
/// Exibe uma notificação persistente com contagem regressiva ao vivo,
/// garantindo que o timer continue funcionando mesmo com o app minimizado.
///
/// No iOS este serviço é no-op (Live Activities / Dynamic Island é usado).
class ForegroundService {
  ForegroundService._internal();

  static final ForegroundService instance = ForegroundService._internal();

  bool _isRunning = false;
  bool _isInitialized = false;

  // ───────────────────────────────────────────────
  // Inicialização
  // ───────────────────────────────────────────────

  void initCommunicationPort() {
    if (!Platform.isAndroid) return;
    FlutterForegroundTask.initCommunicationPort();
  }

  Future<void> requestPermissions() async {
    if (!Platform.isAndroid) return;
    await FlutterForegroundTask.requestIgnoreBatteryOptimization();
    final notificationPermission =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }
  }

  void _ensureInitialized() {
    if (_isInitialized) return;
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'todoin_timer_foreground',
        channelName: 'Timer de Foco – ativo',
        channelDescription:
            'Mantém o timer de foco funcionando em segundo plano',
        channelImportance: NotificationChannelImportance.HIGH,
        priority: NotificationPriority.HIGH,
        enableVibration: false,
        playSound: false,
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        autoRunOnBoot: false,
        allowWifiLock: false,
      ),
    );
    _isInitialized = true;
  }

  // ───────────────────────────────────────────────
  // Iniciar serviço com notificação durante o timer
  // ───────────────────────────────────────────────

  Future<void> startTimerService({int remainingSeconds = 120}) async {
    if (!Platform.isAndroid || _isRunning) return;

    _ensureInitialized();
    final formattedTime = _format(remainingSeconds);

    final result = await FlutterForegroundTask.startService(
      serviceId: 333,
      notificationTitle: '🧠 Foco ativo – $formattedTime',
      notificationText: 'Mantenha o foco! Você consegue.',
    );

    if (result is ServiceRequestSuccess) {
      _isRunning = true;
      debugPrint('[ForegroundService] Serviço iniciado – $formattedTime restantes.');
    } else {
      debugPrint('[ForegroundService] Falha ao iniciar serviço: $result');
    }
  }

  // ───────────────────────────────────────────────
  // Atualizar contador na notificação
  // ───────────────────────────────────────────────

  Future<void> updateTimer(int remainingSeconds) async {
    if (!Platform.isAndroid || !_isRunning) return;

    final formattedTime = _format(remainingSeconds);
    await FlutterForegroundTask.updateService(
      notificationTitle: '🧠 Foco ativo – $formattedTime',
      notificationText: 'Você está concentrado! Continue assim.',
    );
  }

  // ───────────────────────────────────────────────
  // Parar serviço
  // ───────────────────────────────────────────────

  Future<void> stopService() async {
    if (!Platform.isAndroid || !_isRunning) return;
    await FlutterForegroundTask.stopService();
    _isRunning = false;
    debugPrint('[ForegroundService] Serviço encerrado.');
  }

  bool get isRunning => _isRunning;

  String _format(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
