import 'package:flutter/material.dart';

import 'theme_controller.dart';

/// Central Inherited Widget for the light/dark preference.
///
/// Sits above `MaterialApp` so the toggle stays reachable from any pushed
/// route while still driving `MaterialApp.themeMode`.
class ThemeProvider extends InheritedNotifier<ThemeController> {
  const ThemeProvider({
    super.key,
    required super.notifier,
    required super.child,
  });

  static ThemeController of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<ThemeProvider>();
    assert(provider?.notifier != null, 'ThemeProvider not found in context');
    return provider!.notifier!;
  }
}