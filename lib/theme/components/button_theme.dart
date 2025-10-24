import 'package:flutter/material.dart';
import '../colors.dart';
import '../typography.dart';

ButtonThemeData appButtonTheme() {
  return const ButtonThemeData();
}

ElevatedButtonThemeData elevatedButtonStyle() {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.,
      foregroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      textStyle: AppTypography.defaultTextTheme().labelLarge,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
    ),
  );
}
