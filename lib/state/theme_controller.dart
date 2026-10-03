import 'package:flutter/material.dart';

/// Holds the user's light/dark preference.
///
/// Lives for the session only — the app boots in [ThemeMode.light] every time.
class ThemeController extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.light;

  ThemeMode get mode => _mode;

  bool get isDarkMode => _mode == ThemeMode.dark;

  void toggle() {
    _mode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}
