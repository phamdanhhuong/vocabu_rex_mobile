import 'package:flutter/material.dart';
import 'light_theme.dart';
import 'dark_theme.dart';

/// AppTheme exposes light/dark ThemeData and helper to pick by ThemeMode
class AppTheme {
  static ThemeData light() => lightTheme();
  static ThemeData dark() => darkTheme();

  static ThemeData resolve(ThemeMode mode) {
    return mode == ThemeMode.dark ? darkTheme() : lightTheme();
  }
}
