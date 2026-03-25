import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// A floating "+N XP" label that rises and fades out to give
/// immediate positive reinforcement feedback.
///
/// Usage: trigger a rebuild by toggling [visible] true, then false.
/// The animation runs once and disappears automatically.
///
/// Typically wrapped in a [Stack] overlay positioned near the XP badge.
class XpFloatingLabel extends StatelessWidget {
  final int amount;
  final bool visible;

  const XpFloatingLabel({
    super.key,
    this.amount = 10,
    required this.visible,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return IgnorePointer(
      child: Text(
        '+$amount XP',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: colorScheme.tertiary,
          shadows: [
            Shadow(
              color: colorScheme.tertiary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      )
          .animate()
          // Rise up
          .slideY(
            begin: 0,
            end: -1.8,
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOut,
          )
          // Fade in quickly then out
          .fadeIn(duration: const Duration(milliseconds: 150))
          .then(delay: const Duration(milliseconds: 450))
          .fadeOut(duration: const Duration(milliseconds: 300)),
    );
  }
}
