import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';
import 'components/button_theme.dart';

ThemeData darkTheme() {
  final base = ThemeData.dark();

  return base.copyWith(
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.background,
      secondary: AppColors.background,
      background: AppColors.background,
      surface: AppColors.background,
      onPrimary: AppColors.background,
      onSecondary: AppColors.background,
    ),
    scaffoldBackgroundColor: AppColors.background,
    textTheme: AppTypography.defaultTextTheme(AppColors.white),
    elevatedButtonTheme: elevatedButtonStyle(),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.white,
      elevation: 0,
      centerTitle: true,
    ),
  );
}
