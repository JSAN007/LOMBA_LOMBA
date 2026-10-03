import 'package:flutter/material.dart';

/// Accent colors that stay constant across both themes.
///
/// Level identities, medals and brand marks keep their meaning regardless of
/// brightness; only surfaces, text and borders swap via [CyberPalette].
class CyberColors {
  const CyberColors._();

  // Pastel Accent Colors
  static const Color primary = Color(0xFF7BA4E0); // Soft Blue
  static const Color primaryLight = Color(0xFFA8C8F0); // Lighter Blue
  static const Color secondary = Color(0xFFB09DE0); // Soft Lavender
  static const Color accentGreen = Color(0xFF7DD3A8); // Soft Mint
  static const Color accentRed = Color(0xFFE8A0A0); // Soft Rose
  static const Color accentYellow = Color(0xFFF2CB6C); // Soft Honey
  static const Color accentOrange = Color(0xFFF0B080); // Soft Peach

  // Rank medals — identity colors, not theme roles
  static const Color rankGold = Color(0xFFF5D56B);
  static const Color rankSilver = Color(0xFFC9D6E6);
  static const Color rankBronze = Color(0xFFE8B08A);

  // Vivid gradient for the primary call-to-action
  static const Color ctaStart = Color(0xFF27AE60);
  static const Color ctaEnd = Color(0xFF2ECC71);
}

/// Theme-aware colour roles.
///
/// Attached to [ThemeData] through `extensions:` and read with
/// `context.cyber`. This is the single source of truth for backgrounds,
/// surfaces, text and borders, so text is always readable: dark ink on light
/// surfaces, light ink on dark surfaces — without any per-widget branching.
@immutable
class CyberPalette extends ThemeExtension<CyberPalette> {
  const CyberPalette({
    required this.brightness,
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.surfaceSunken,
    required this.border,
    required this.borderStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.onAccent,
    required this.shadow,
    required this.navbarActive,
    required this.navbarInactive,
  });

  final Brightness brightness;

  /// Page background behind every screen.
  final Color background;

  /// Raised card / sheet surface.
  final Color surface;

  /// Subtly filled surface: icon chips, snackbars, locked tiles.
  final Color surfaceAlt;

  /// Recessed surface for nested content inside a card.
  final Color surfaceSunken;

  /// Hairline divider and card outline.
  final Color border;

  /// Emphasised border, also used as the `outline` colour role.
  final Color borderStrong;

  /// Headings and primary body copy.
  final Color textPrimary;

  /// Supporting copy.
  final Color textSecondary;

  /// De-emphasised copy and inactive icons.
  final Color textMuted;

  /// Ink for text and icons sitting on top of a saturated accent fill.
  ///
  /// The accents are pastel, so dark ink stays legible in *both* themes —
  /// white ink on them would drop below the 3:1 contrast floor.
  final Color onAccent;

  /// Shadow and scrim tint.
  final Color shadow;

  /// Active navigation bar item.
  final Color navbarActive;

  /// Inactive navigation bar item.
  final Color navbarInactive;

  static const CyberPalette light = CyberPalette(
    brightness: Brightness.light,
    background: Color(0xFFF7F8FC),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF0F2F8),
    surfaceSunken: Color(0xFFF5F6FA),
    border: Color(0xFFE2E6F0),
    borderStrong: Color(0xFFD5DAE8),
    textPrimary: Color(0xFF2D3142),
    textSecondary: Color(0xFF636B8C),
    textMuted: Color(0xFF818AA8),
    onAccent: Color(0xFF161A24),
    shadow: Color(0xFF2D3142),
    navbarActive: Color(0xFF3E6FB8),
    navbarInactive: Color(0xFF848BA7),
  );

  static const CyberPalette dark = CyberPalette(
    brightness: Brightness.dark,
    background: Color(0xFF12141F),
    surface: Color(0xFF1C1F2E),
    surfaceAlt: Color(0xFF262A3B),
    surfaceSunken: Color(0xFF171A27),
    border: Color(0xFF2C3145),
    borderStrong: Color(0xFF3B4159),
    textPrimary: Color(0xFFF2F4FA),
    textSecondary: Color(0xFFB6BCCE),
    textMuted: Color(0xFF8E96B2),
    onAccent: Color(0xFF0E1018),
    shadow: Color(0xFF000000),
    navbarActive: Color(0xFF93BAF0),
    navbarInactive: Color(0xFF7E86A3),
  );

  /// Neutral grey ramp used by the simulated email client in the lesson
  /// screen. It models a third-party app, so it stays light in every theme.
  static const Color mailChrome = Color(0xFFF1F5F9);
  static const Color mailBody = Color(0xFFFAFAFA);
  static const Color mailInk = Color(0xFF1F2430);
  static const Color mailInkMuted = Color(0xFF5A6172);
  static const Color mailHairline = Color(0x1A000000);

  @override
  CyberPalette copyWith({
    Brightness? brightness,
    Color? background,
    Color? surface,
    Color? surfaceAlt,
    Color? surfaceSunken,
    Color? border,
    Color? borderStrong,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? onAccent,
    Color? shadow,
    Color? navbarActive,
    Color? navbarInactive,
  }) {
    return CyberPalette(
      brightness: brightness ?? this.brightness,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      surfaceSunken: surfaceSunken ?? this.surfaceSunken,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      onAccent: onAccent ?? this.onAccent,
      shadow: shadow ?? this.shadow,
      navbarActive: navbarActive ?? this.navbarActive,
      navbarInactive: navbarInactive ?? this.navbarInactive,
    );
  }

  @override
  CyberPalette lerp(CyberPalette? other, double t) {
    if (other == null) return this;
    return CyberPalette(
      brightness: t < 0.5 ? brightness : other.brightness,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      surfaceSunken: Color.lerp(surfaceSunken, other.surfaceSunken, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      navbarActive: Color.lerp(navbarActive, other.navbarActive, t)!,
      navbarInactive: Color.lerp(navbarInactive, other.navbarInactive, t)!,
    );
  }
}

/// Convenience access to the active [CyberPalette].
extension CyberPaletteContext on BuildContext {
  CyberPalette get cyber =>
      Theme.of(this).extension<CyberPalette>() ?? CyberPalette.light;
}
