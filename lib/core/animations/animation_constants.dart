import 'package:flutter/material.dart';

/// Centralized animation constants for consistent UX across the app.
/// All durations follow the ADHD-friendly 300ms–800ms guideline.
abstract class AppAnimations {
  // ── Durations ─────────────────────────────────────────────────────────────
  static const Duration fast = Duration(milliseconds: 300);
  static const Duration medium = Duration(milliseconds: 450);
  static const Duration normal = Duration(milliseconds: 600);
  static const Duration slow = Duration(milliseconds: 800);

  // Per-item stagger offset for list animations
  static const Duration staggerOffset = Duration(milliseconds: 60);

  // ── Curves ────────────────────────────────────────────────────────────────
  static const Curve entryEase = Curves.easeOut;
  static const Curve bounceEntry = Curves.elasticOut;
  static const Curve tapScale = Curves.easeOutCubic;

  // ── Scale values ──────────────────────────────────────────────────────────
  static const double tapScaleDown = 0.94;
  static const double tapScaleNormal = 1.0;

  // ── Slide offsets (used with flutter_animate .slideY) ────────────────────
  /// Fraction of the widget height to slide from (positive = from below)
  static const double slideFromBelow = 0.12;
}
