import 'package:shared_preferences/shared_preferences.dart';

class OnboardingLocalDataSource {
  static const _key = 'onboarding_completed';

  final SharedPreferences prefs;

  OnboardingLocalDataSource(this.prefs);

  Future<bool> isCompleted() async => prefs.getBool(_key) ?? false;

  Future<void> markCompleted() async {
    await prefs.setBool(_key, true);
  }
}
