import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'animation_constants.dart';
import '../services/feedback_service.dart';

/// A wrapper widget that applies a subtle scale-down effect on tap,
/// providing tactile visual feedback — especially useful for ADHD users.
///
/// Example:
/// ```dart
/// ScaleTap(
///   onTap: () => doSomething(),
///   child: MyButton(),
/// )
/// ```
class ScaleTap extends StatefulWidget {
  final VoidCallback? onTap;
  final Widget child;
  final double scaleDown;
  final Duration duration;
  final bool useHaptic;

  const ScaleTap({
    super.key,
    required this.child,
    this.onTap,
    this.scaleDown = AppAnimations.tapScaleDown,
    this.duration = AppAnimations.fast,
    this.useHaptic = false,
  });

  @override
  State<ScaleTap> createState() => _ScaleTapState();
}

class _ScaleTapState extends State<ScaleTap> {
  bool _pressed = false;

  void _onTapDown(TapDownDetails _) => setState(() => _pressed = true);

  void _onTapUp(TapUpDetails _) {
    setState(() => _pressed = false);
    if (widget.useHaptic) FeedbackService.click();
    widget.onTap?.call();
  }

  void _onTapCancel() => setState(() => _pressed = false);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? widget.scaleDown : AppAnimations.tapScaleNormal,
        duration: widget.duration,
        curve: AppAnimations.tapScale,
        child: widget.child,
      ),
    );
  }
}
