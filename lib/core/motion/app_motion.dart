import 'package:flutter/material.dart';

/// Motion and animation tokens for SecuriGo.
class AppMotion {
  const AppMotion._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration base = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration countUp = Duration(milliseconds: 900);
  static const Duration progressFill = Duration(milliseconds: 900);
  static const Duration skeletonCrossfade = Duration(milliseconds: 300);
  static const Duration fadeThroughIn = Duration(milliseconds: 220);
  static const Duration fadeThroughOut = Duration(milliseconds: 120);
  static const Duration slideUp = Duration(milliseconds: 300);

  /// Stagger step for list/item entrance animations.
  static const Duration staggerStep = Duration(milliseconds: 70);

  /// Intro skeleton minimum display duration to feel natural.
  static const Duration introSkeletonMin = Duration(milliseconds: 600);

  /// Intro total target duration.
  static const Duration introTotal = Duration(seconds: 2);

  // Curves
  static const Curve standard = Curves.easeOutCubic;
  static const Curve pop = Curves.easeOutBack;
  static const Curve smooth = Curves.easeInOutCubic;

  /// Breathing glow animation duration.
  static const Duration breathingGlow = Duration(milliseconds: 2500);

  /// Idle floating duration for mascot.
  static const Duration floatIdle = Duration(seconds: 3);

  /// Whether animations should be reduced based on system settings.
  static bool reduceAnimations(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }
}
