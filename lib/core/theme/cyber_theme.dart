import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'cyber_colors.dart';

class CyberTheme {
  static TextTheme get _nunitoTextTheme {
    return GoogleFonts.nunitoTextTheme(
      const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: CyberColors.textPrimary,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: CyberColors.textPrimary,
          letterSpacing: -0.2,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: CyberColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: CyberColors.textPrimary,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: CyberColors.textSecondary,
          height: 1.4,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: CyberColors.background,
      colorScheme: const ColorScheme.dark(
        primary: CyberColors.primary,
        secondary: CyberColors.secondary,
        surface: CyberColors.surface,
        error: CyberColors.accentRed,
      ),
      cardTheme: CardThemeData(
        color: CyberColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: CyberColors.border, width: 1),
        ),
        elevation: 0,
      ),
      textTheme: _nunitoTextTheme,
    );
  }
}
