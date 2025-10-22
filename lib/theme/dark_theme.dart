import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';
import 'components/button_theme.dart';

ThemeData darkTheme() {
  final base = ThemeData.dark();

  return base.copyWith(
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.brandDarkGreen,
      secondary: AppColors.accentOrange,
      background: AppColors.gray700,
      surface: AppColors.gray400,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
    ),
    scaffoldBackgroundColor: AppColors.gray700,
    textTheme: AppTypography.defaultTextTheme(AppColors.white),
    elevatedButtonTheme: elevatedButtonStyle(),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.gray700,
      foregroundColor: AppColors.white,
      elevation: 0,
      centerTitle: true,
    ),
  );
}
