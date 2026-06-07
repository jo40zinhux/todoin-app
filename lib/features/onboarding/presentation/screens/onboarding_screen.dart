import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/animations/animation_constants.dart';
import '../../../../core/constants/legal_urls.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/feedback_service.dart';
import '../../../../core/usecases/usecase.dart';
import '../providers/onboarding_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingPageData(
      icon: Icons.bolt_rounded,
      title: 'Comece pequeno',
      body:
          'O toDoin divide tarefas em passos pequenos para você não travar antes de começar.',
    ),
    _OnboardingPageData(
      icon: Icons.timer_outlined,
      title: 'Foque por 2 minutos',
      body:
          'Um timer curto ajuda seu cérebro a entrar em ação sem pressão de horas.',
    ),
    _OnboardingPageData(
      icon: Icons.favorite_outline_rounded,
      title: 'Sem culpa, só progresso',
      body:
          'Dias difíceis acontecem. O app celebra o que você fez — não o que faltou.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    FeedbackService.click();
    await ref.read(completeOnboardingProvider)(NoParams());
    AnalyticsService.instance.onboardingCompleted();
    await ref.read(onboardingCompletedStateProvider.notifier).refresh();
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          page.icon,
                          size: 72,
                          color: colorScheme.primary,
                        )
                            .animate()
                            .fadeIn(duration: AppAnimations.normal)
                            .scale(
                              begin: const Offset(0.8, 0.8),
                              duration: AppAnimations.normal,
                            ),
                        const SizedBox(height: 32),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        )
                            .animate()
                            .fadeIn(
                              delay: AppAnimations.fast,
                              duration: AppAnimations.normal,
                            ),
                        const SizedBox(height: 16),
                        Text(
                          page.body,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurface.withOpacity( 0.7),
                            height: 1.5,
                          ),
                        )
                            .animate()
                            .fadeIn(
                              delay: AppAnimations.normal,
                              duration: AppAnimations.normal,
                            ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: AppAnimations.fast,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i
                        ? colorScheme.primary
                        : colorScheme.outline.withOpacity( 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    FeedbackService.click();
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: AppAnimations.normal,
                        curve: AppAnimations.entryEase,
                      );
                    } else {
                      _finish();
                    }
                  },
                  child: Text(
                    _currentPage < _pages.length - 1
                        ? 'Continuar'
                        : 'Começar agora',
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () => _openUrl(LegalUrls.privacyPolicy),
              child: const Text('Política de Privacidade'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  final IconData icon;
  final String title;
  final String body;

  const _OnboardingPageData({
    required this.icon,
    required this.title,
    required this.body,
  });
}
