import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

/// Serviço singleton de notificações locais.
/// Responsável por inicializar o plugin e disparar a notificação
/// quando o timer de foco é concluído.
class NotificationService {
  NotificationService._internal();

  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // ───────────────────────────────────────────────
  // Inicialização
  // ───────────────────────────────────────────────

  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // Solicitar permissão explicitamente no Android 13+
    if (Platform.isAndroid) {
      final androidImpl = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidImpl?.requestNotificationsPermission();
    }

    if (Platform.isIOS) {
      final iosImpl = _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      await iosImpl?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    _initialized = true;
    debugPrint('[NotificationService] Inicializado com sucesso.');
  }

  void _onNotificationResponse(NotificationResponse response) {
    debugPrint('[NotificationService] Notificação tocada: ${response.id}');
  }

  // ───────────────────────────────────────────────
  // Notificação: Timer Concluído
  // ───────────────────────────────────────────────

  static const int _timerCompleteId = 1001;
  static const String _channelId = 'todoin_timer';
  static const String _channelName = 'Timer de Foco';
  static const String _channelDesc = 'Notificações do timer de foco toDoin';

  Future<void> showTimerCompleteNotification() async {
    if (!_initialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'Timer concluído!',
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(
        'Você manteve o foco por 2 minutos! Continue assim. 🚀',
        summaryText: 'toDoin Focus',
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      subtitle: 'Sessão de foco encerrada',
      threadIdentifier: 'todoin_timer',
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      _timerCompleteId,
      '⏱️ Timer concluído!',
      'Você focou por 2 minutos. Cada passo conta! 🎉',
      details,
    );

    debugPrint('[NotificationService] Notificação de conclusão disparada.');
  }

  // ───────────────────────────────────────────────
  // Cancelar
  // ───────────────────────────────────────────────

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
    debugPrint('[NotificationService] Todas as notificações canceladas.');
  }

  // ───────────────────────────────────────────────
  // Lembretes gentis (Pro)
  // ───────────────────────────────────────────────

  static const int _gentleReminderId = 2001;
  static const String _reminderChannelId = 'todoin_reminders';
  static const String _reminderChannelName = 'Lembretes Gentis';
  static const String _reminderChannelDesc =
      'Lembretes suaves para começar uma tarefa';

  Future<void> scheduleGentleReminder({
    required int hour,
    required int minute,
    required String message,
  }) async {
    if (!_initialized) await initialize();

    await cancelGentleReminders();

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      _reminderChannelId,
      _reminderChannelName,
      channelDescription: _reminderChannelDesc,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: true,
      threadIdentifier: 'todoin_reminders',
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      _gentleReminderId,
      'toDoin 💜',
      message,
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    debugPrint(
      '[NotificationService] Lembrete agendado para ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}.',
    );
  }

  Future<void> cancelGentleReminders() async {
    await _plugin.cancel(_gentleReminderId);
  }
}
