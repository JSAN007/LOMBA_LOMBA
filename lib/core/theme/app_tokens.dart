import 'package:flutter/material.dart';

/// Design tokens for SecuriGo.
class AppTokens {
  const AppTokens._();

  // Spacing
  static const double spacing4 = 4;
  static const double spacing8 = 8;
  static const double spacing12 = 12;
  static const double spacing16 = 16;
  static const double spacing20 = 20;
  static const double spacing24 = 24;

  // Radius
  static const double radiusCard = 24;
  static const double radiusCardSm = 20;
  static const double radiusButton = 18;
  static const double radiusChip = 999;
  static const double radiusPill = 28;
  static const double radiusFrame = 32;

  // Elevation/Shadows
  static const double frameShadowBlur = 40;
  static const Offset frameShadowOffset = Offset(0, 16);

  // Frame dimensions
  static const double frameMaxWidth = 430;
  static const double frameMaxHeight = 920;
  static const double frameMargin = 16;

  // Breakpoint
  static const double desktopBreakpoint = 600;

  // Tint opacities for accent backgrounds
  static const double tintLow = 0.12;
  static const double tintMid = 0.16;
  static const double tintHigh = 0.18;

  // Blobs
  static const double blobSize1 = 280;
  static const double blobSize2 = 220;
  static const double blobBlur = 120;

  // Tap target
  static const double minTapTarget = 44;

  /// Build a tinted color from [base] with [opacity].
  static Color tint(Color base, double opacity) {
    return base.withValues(alpha: opacity.clamp(0, 1));
  }

  /// Get accent tint color for a given accent base color.
  static Color accentTint(Color accent) {
    return tint(accent, tintMid);
  }
}

extension AppTokensContext on BuildContext {
  AppTokens get tokens => const AppTokens._();
}
