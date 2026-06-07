import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/onboarding/presentation/providers/onboarding_provider.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/tasks/presentation/screens/home_screen.dart';
import '../services/analytics_service.dart';

/// Decide entre onboarding e home com base no estado persistido.
class AppBootstrap extends ConsumerWidget {
  const AppBootstrap({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.watch(onboardingCompletedStateProvider);

    return onboardingState.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const HomeScreen(),
      data: (completed) {
        if (completed) {
          AnalyticsService.instance.screen('home');
          return const HomeScreen();
        }
        AnalyticsService.instance.screen('onboarding');
        return const OnboardingScreen();
      },
    );
  }
}
