import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/shared_preferences_provider.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/datasources/onboarding_local_datasource.dart';
import '../../data/repositories/onboarding_repository_impl.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../../domain/usecases/complete_onboarding.dart';
import '../../domain/usecases/is_onboarding_completed.dart';

final onboardingDataSourceProvider = Provider<OnboardingLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return OnboardingLocalDataSource(prefs);
});

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return OnboardingRepositoryImpl(ref.watch(onboardingDataSourceProvider));
});

final isOnboardingCompletedProvider = Provider<IsOnboardingCompleted>((ref) {
  return IsOnboardingCompleted(ref.watch(onboardingRepositoryProvider));
});

final completeOnboardingProvider = Provider<CompleteOnboarding>((ref) {
  return CompleteOnboarding(ref.watch(onboardingRepositoryProvider));
});

final onboardingCompletedStateProvider =
    StateNotifierProvider<OnboardingStateNotifier, AsyncValue<bool>>((ref) {
  return OnboardingStateNotifier(ref.watch(isOnboardingCompletedProvider));
});

class OnboardingStateNotifier extends StateNotifier<AsyncValue<bool>> {
  final IsOnboardingCompleted _isCompleted;

  OnboardingStateNotifier(this._isCompleted) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final completed = await _isCompleted(NoParams());
      state = AsyncValue.data(completed);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() => _load();
}
