import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';
import 'components/button_theme.dart';

ThemeData lightTheme() {
  final base = ThemeData.light();

  return base.copyWith(
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.background,
      secondary: AppColors.background,
      background: AppColors.background,
      surface: AppColors.white,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
    ),
    scaffoldBackgroundColor: AppColors.background,
    textTheme: AppTypography.defaultTextTheme(AppColors.black),
    elevatedButtonTheme: elevatedButtonStyle(),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.black,
      elevation: 0,
      centerTitle: true,
    ),
  );
}
