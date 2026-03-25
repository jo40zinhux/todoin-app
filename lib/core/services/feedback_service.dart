import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

class FeedbackService {
  static bool soundEnabled = true;
  static bool hapticEnabled = true;

  static Future<void> _playSound(String file) async {
    if (!soundEnabled) return;
    // Delay de 50ms para melhorar a percepção entre animação e som
    await Future.delayed(const Duration(milliseconds: 50));
    final player = AudioPlayer();
    await player.play(AssetSource('sounds/$file'));
    player.onPlayerComplete.listen((event) {
      player.dispose();
    });
  }

  static Future<void> _vibrate(int duration) async {
    if (!hapticEnabled) return;
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: duration);
    }
  }

  static Future<void> click() async {
    _playSound('click.mp3');
    _vibrate(10);
  }

  static Future<void> subtaskDone() async {
    _playSound('subtle_pop.mp3');
    _vibrate(15);
  }

  static Future<void> success() async {
    _playSound('success.mp3');
    _vibrate(40);
  }

  static Future<void> xp() async {
    _playSound('xp.mp3');
    _vibrate(20);
  }

  static Future<void> timerDone() async {
    _playSound('timer_done.mp3');
    _vibrate(60);
  }
}
