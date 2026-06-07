import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/live_activity_service.dart';
import '../../../../core/services/foreground_service.dart';
import '../../../../core/services/feedback_service.dart';

/// Widget de timer de foco de 2 minutos.
///
/// Ao iniciar:
/// - iOS: inicia uma Live Activity (Dynamic Island / tela de bloqueio)
/// - Android: inicia um foreground service com notificação persistente
///
/// Ao finalizar:
/// - Dispara notificação local em ambas as plataformas
/// - Encerra a Live Activity / foreground service
class TimerWidget extends StatefulWidget {
  final int durationSeconds;
  final String taskTitle;
  final VoidCallback? onComplete;

  const TimerWidget({
    super.key,
    this.durationSeconds = 120,
    this.taskTitle = 'Foco ativo',
    this.onComplete,
  });

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget>
    with SingleTickerProviderStateMixin {
  late final int _totalSeconds;
  late int _remaining;
  Timer? _timer;
  bool _finished = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _totalSeconds = widget.durationSeconds;
    _remaining = _totalSeconds;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation =
        Tween<double>(begin: 1.0, end: 1.08).animate(_pulseController);

    _startBackgroundFeatures();
    _startTimer();
  }

  /// Inicia Live Activity (iOS) ou Foreground Service (Android).
  Future<void> _startBackgroundFeatures() async {
    if (Platform.isIOS) {
      await LiveActivityService.instance.startTimerActivity(
        totalSeconds: _totalSeconds,
        taskTitle: widget.taskTitle,
      );
    } else if (Platform.isAndroid) {
      await ForegroundService.instance.startTimerService(
        remainingSeconds: _totalSeconds,
      );
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining <= 1) {
        timer.cancel();
        setState(() {
          _remaining = 0;
          _finished = true;
        });
        _pulseController.stop();
        _onTimerComplete();
      } else {
        setState(() {
          _remaining--;
        });
        _updateBackgroundFeatures(_remaining);
      }
    });
  }

  /// Atualiza Live Activity (iOS) ou a notificação do foreground service (Android).
  Future<void> _updateBackgroundFeatures(int remaining) async {
    if (Platform.isIOS) {
      await LiveActivityService.instance.updateTimerActivity(
        remainingSeconds: remaining,
      );
    } else if (Platform.isAndroid) {
      await ForegroundService.instance.updateTimer(remaining);
    }
  }

  /// Chamado quando o timer finaliza: dispara notificação e encerra serviços.
  Future<void> _onTimerComplete() async {
    FeedbackService.timerDone();
    // Disparar notificação local (funciona mesmo com app minimizado)
    await NotificationService.instance.showTimerCompleteNotification();

    // Encerrar serviços de background
    if (Platform.isIOS) {
      await LiveActivityService.instance.endTimerActivity(completed: true);
    } else if (Platform.isAndroid) {
      await ForegroundService.instance.stopService();
    }

    widget.onComplete?.call();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();

    // Encerrar serviços se o usuário cancelar antes do fim
    if (!_finished) {
      if (Platform.isIOS) {
        LiveActivityService.instance.endTimerActivity(completed: false);
      } else if (Platform.isAndroid) {
        ForegroundService.instance.stopService();
      }
    }

    super.dispose();
  }

  String get _formattedTime {
    final minutes = (_remaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  double get _progress => _remaining / _totalSeconds;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog.fullscreen(
      backgroundColor: colorScheme.surface,
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _finished ? '🎉' : '🧠 Foco ativo',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (!_finished && widget.taskTitle.isNotEmpty) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  widget.taskTitle,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 48),
            ScaleTransition(
              scale: _finished
                  ? const AlwaysStoppedAnimation(1.0)
                  : _pulseAnimation,
              child: SizedBox(
                width: 220,
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: 12,
                        color: colorScheme.surfaceContainerHighest,
                      ),
                    ),
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: CircularProgressIndicator(
                        value: _progress,
                        strokeWidth: 12,
                        strokeCap: StrokeCap.round,
                        color: _finished
                            ? colorScheme.tertiary
                            : colorScheme.primary,
                      ),
                    ),
                    Text(
                      _finished ? '✓' : _formattedTime,
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: _finished
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'Você começou, isso já conta! 🎉\nCada passo importa.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.tertiary,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                        ),
                      ),
                    )
                  : Text(
                      'Mantenha o foco, você consegue!',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
            ),
            const SizedBox(height: 48),
            FilledButton.tonal(
              onPressed: () {
                FeedbackService.click();
                Navigator.of(context).pop(_finished);
              },
              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                _finished ? 'Voltar' : 'Cancelar',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
