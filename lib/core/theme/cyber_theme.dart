import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'cyber_colors.dart';

/// Builds the two app themes from a single [CyberPalette] definition.
///
/// Everything that carries meaning for readability — scaffold, surfaces,
/// text, borders, dialogs, snackbars, switches — is derived from the palette
/// so no widget has to know which mode is active.
class CyberTheme {
  const CyberTheme._();

  static ThemeData get light => _build(CyberPalette.light);
  static ThemeData get dark => _build(CyberPalette.dark);

  static ColorScheme _colorScheme(CyberPalette p) {
    final isDark = p.brightness == Brightness.dark;

    return ColorScheme(
      brightness: p.brightness,
      primary: CyberColors.primary,
      onPrimary: p.onAccent,
      primaryContainer: isDark ? const Color(0xFF2A3A57) : const Color(0xFFDCE8FA),
      onPrimaryContainer: isDark ? const Color(0xFFCFE1FA) : const Color(0xFF1B3A66),
      secondary: CyberColors.secondary,
      onSecondary: p.onAccent,
      secondaryContainer: isDark ? const Color(0xFF382F52) : const Color(0xFFEAE4F8),
      onSecondaryContainer: isDark ? const Color(0xFFDDD2F5) : const Color(0xFF3F2F6B),
      tertiary: CyberColors.accentGreen,
      onTertiary: p.onAccent,
      tertiaryContainer: isDark ? const Color(0xFF24483A) : const Color(0xFFDDF2E8),
      onTertiaryContainer: isDark ? const Color(0xFFC6EEDD) : const Color(0xFF14503A),
      error: CyberColors.accentRed,
      onError: p.onAccent,
      errorContainer: isDark ? const Color(0xFF4A2429) : const Color(0xFFFBE3E3),
      onErrorContainer: isDark ? const Color(0xFFF7CFCF) : const Color(0xFF6B2222),
      surface: p.surface,
      onSurface: p.textPrimary,
      onSurfaceVariant: p.textSecondary,
      surfaceContainerLowest: p.background,
      surfaceContainerLow: p.background,
      surfaceContainer: p.surfaceAlt,
      surfaceContainerHigh: p.surfaceAlt,
      surfaceContainerHighest: p.surfaceAlt,
      surfaceTint: Colors.transparent,
      inverseSurface: p.textPrimary,
      onInverseSurface: p.background,
      inversePrimary: CyberColors.primaryLight,
      outline: p.borderStrong,
      outlineVariant: p.border,
      shadow: p.shadow,
      scrim: p.shadow,
    );
  }

  static TextTheme _nunitoTextTheme(CyberPalette p) {
    // `.black` is only the starting ramp — every colour is overridden below by
    // `.apply`, which is what keeps light mode on dark ink and dark mode on
    // light ink no matter which role a widget picks.
    final ramp = Typography.material2021(platform: defaultTargetPlatform).black;

    final base = GoogleFonts.nunitoTextTheme(ramp).apply(
      bodyColor: p.textPrimary,
      displayColor: p.textPrimary,
    );

    return base.copyWith(
      headlineLarge: base.headlineLarge?.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: p.textPrimary,
        letterSpacing: -0.5,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: p.textPrimary,
        letterSpacing: -0.2,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: p.textPrimary,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: p.textPrimary,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: p.textPrimary,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: p.textPrimary,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 16,
        color: p.textPrimary,
        height: 1.5,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 14,
        color: p.textSecondary,
        height: 1.4,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 12,
        color: p.textSecondary,
        height: 1.35,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: p.textPrimary,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: p.textPrimary,
      ),
      // labelSmall renders at 11px, so it holds the 4.5:1 bar rather than
      // the 3:1 that `textMuted` is cleared for.
      labelSmall: base.labelSmall?.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: p.textSecondary,
      ),
    );
  }

  static ThemeData _build(CyberPalette p) {
    final colorScheme = _colorScheme(p);
    final textTheme = _nunitoTextTheme(p);

    return ThemeData(
      useMaterial3: true,
      brightness: p.brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: p.background,
      textTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[p],
      cardTheme: CardThemeData(
        color: p.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: p.border, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        foregroundColor: p.textPrimary,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        contentTextStyle: textTheme.bodyMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        // Inverted chip: dark on light, light on dark — always readable.
        backgroundColor: p.textPrimary,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: p.background,
          fontWeight: FontWeight.w600,
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        // Matches the app's column inset and the 28px navbar radius.
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: DividerThemeData(
        color: p.border,
        thickness: 1,
        space: 1,
      ),
      iconTheme: IconThemeData(color: p.textPrimary),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? CyberColors.primary
                : p.surfaceAlt),
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? p.onAccent : p.textMuted),
        trackOutlineColor: WidgetStatePropertyAll(p.borderStrong),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: p.textSecondary,
        textColor: p.textPrimary,
      ),
      splashFactory: InkSparkle.splashFactory,
    );
  }
}