import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'animation_constants.dart';

/// Wraps [child] in a fade + vertical slide entrance animation.
///
/// Use [delay] to stagger list items:
/// ```dart
/// AnimatedListItem(delay: Duration(milliseconds: index * 60), child: ...)
/// ```
class AnimatedListItem extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final double slideOffset;

  const AnimatedListItem({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = AppAnimations.medium,
    this.slideOffset = AppAnimations.slideFromBelow,
  });

  @override
  Widget build(BuildContext context) {
    return child
        .animate(delay: delay)
        .fadeIn(duration: duration, curve: AppAnimations.entryEase)
        .slideY(
          begin: slideOffset,
          end: 0,
          duration: duration,
          curve: AppAnimations.entryEase,
        );
  }
}
