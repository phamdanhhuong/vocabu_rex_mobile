import 'package:flutter/material.dart';

/// App typography inspired by Duolingo: friendly, rounded, legible.
class AppTypography {
  // Primary font family - fallback to system if custom font not provided.
  static const String primaryFont = 'Inter';

  static TextTheme defaultTextTheme([Color? color]) {
    final baseColor = color ?? Colors.black;

    return TextTheme(
      displayLarge: TextStyle(fontFamily: primaryFont, fontSize: 40, fontWeight: FontWeight.w700, color: baseColor),
      displayMedium: TextStyle(fontFamily: primaryFont, fontSize: 34, fontWeight: FontWeight.w700, color: baseColor),
      displaySmall: TextStyle(fontFamily: primaryFont, fontSize: 28, fontWeight: FontWeight.w700, color: baseColor),

      headlineLarge: TextStyle(fontFamily: primaryFont, fontSize: 22, fontWeight: FontWeight.w600, color: baseColor),
      headlineMedium: TextStyle(fontFamily: primaryFont, fontSize: 20, fontWeight: FontWeight.w600, color: baseColor),
      headlineSmall: TextStyle(fontFamily: primaryFont, fontSize: 18, fontWeight: FontWeight.w600, color: baseColor),

      titleLarge: TextStyle(fontFamily: primaryFont, fontSize: 16, fontWeight: FontWeight.w600, color: baseColor),
      titleMedium: TextStyle(fontFamily: primaryFont, fontSize: 14, fontWeight: FontWeight.w500, color: baseColor),
      titleSmall: TextStyle(fontFamily: primaryFont, fontSize: 12, fontWeight: FontWeight.w500, color: baseColor),

      bodyLarge: TextStyle(fontFamily: primaryFont, fontSize: 16, fontWeight: FontWeight.w400, color: baseColor),
      bodyMedium: TextStyle(fontFamily: primaryFont, fontSize: 14, fontWeight: FontWeight.w400, color: baseColor),
      bodySmall: TextStyle(fontFamily: primaryFont, fontSize: 12, fontWeight: FontWeight.w400, color: baseColor),

      labelLarge: TextStyle(fontFamily: primaryFont, fontSize: 14, fontWeight: FontWeight.w600, color: baseColor),
      labelSmall: TextStyle(fontFamily: primaryFont, fontSize: 11, fontWeight: FontWeight.w600, color: baseColor),
    );
  }
}
