import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todoin_focus_app/core/services/feedback_service.dart';
import 'package:todoin_focus_app/core/usecases/usecase.dart';
import 'package:todoin_focus_app/features/settings/domain/entities/app_settings.dart';
import 'package:todoin_focus_app/features/settings/domain/usecases/get_settings.dart';
import 'package:todoin_focus_app/features/settings/domain/usecases/toggle_bad_day_mode.dart';
import 'package:todoin_focus_app/features/settings/domain/usecases/toggle_haptic_setting.dart';
import 'package:todoin_focus_app/features/settings/domain/usecases/toggle_sound_setting.dart';
import 'package:todoin_focus_app/features/settings/presentation/providers/settings_provider.dart';

class MockGetSettings extends Mock implements GetSettings {}

class MockToggleSoundSetting extends Mock implements ToggleSoundSetting {}

class MockToggleHapticSetting extends Mock implements ToggleHapticSetting {}

class MockToggleBadDayMode extends Mock implements ToggleBadDayMode {}

void main() {
  late MockGetSettings mockGetSettings;
  late MockToggleSoundSetting mockToggleSound;
  late MockToggleHapticSetting mockToggleHaptic;
  late MockToggleBadDayMode mockToggleBadDay;
  late SettingsNotifier notifier;

  setUp(() {
    registerFallbackValue(NoParams());

    mockGetSettings = MockGetSettings();
    mockToggleSound = MockToggleSoundSetting();
    mockToggleHaptic = MockToggleHapticSetting();
    mockToggleBadDay = MockToggleBadDayMode();

    notifier = SettingsNotifier(
      const AppSettings(),
      mockGetSettings,
      mockToggleSound,
      mockToggleHaptic,
      mockToggleBadDay,
    );

    FeedbackService.soundEnabled = true;
    FeedbackService.hapticEnabled = true;
  });

  tearDown(() {
    FeedbackService.soundEnabled = true;
    FeedbackService.hapticEnabled = true;
  });

  group('SettingsNotifier', () {
    test('load fetches settings and syncs FeedbackService', () async {
      when(() => mockGetSettings(any()))
          .thenAnswer((_) async => const AppSettings(
                soundEnabled: false,
                hapticEnabled: false,
              ));

      await notifier.load();

      expect(notifier.state, const AppSettings(soundEnabled: false, hapticEnabled: false));
      expect(FeedbackService.soundEnabled, isFalse);
      expect(FeedbackService.hapticEnabled, isFalse);
      verify(() => mockGetSettings(any())).called(1);
    });

    test('toggleSound updates state and FeedbackService', () async {
      when(() => mockToggleSound(any())).thenAnswer((_) async => false);

      await notifier.toggleSound();

      expect(notifier.state.soundEnabled, isFalse);
      expect(FeedbackService.soundEnabled, isFalse);
      verify(() => mockToggleSound(true)).called(1);
    });

    test('toggleHaptic updates state and FeedbackService', () async {
      when(() => mockToggleHaptic(any())).thenAnswer((_) async => false);

      await notifier.toggleHaptic();

      expect(notifier.state.hapticEnabled, isFalse);
      expect(FeedbackService.hapticEnabled, isFalse);
      verify(() => mockToggleHaptic(true)).called(1);
    });
  });
}
