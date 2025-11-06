import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

class AppChoiceTileTokens {
  // Padding
  static double paddingHorizontal = 16.w;
  static double paddingVertical = 12.h;

  // Border
  static double borderRadius = 12.r;
  static double borderWidth = 2.w;

  // Typography
  static double fontSize = 16.sp;
  static FontWeight fontWeight = FontWeight.w600;

  // Default state colors
  static Color backgroundColorDefault = AppColors.snow;
  static Color borderColorDefault = AppColors.swan;
  static Color textColorDefault = AppColors.eel;

  // Selected state colors
  static Color backgroundColorSelected = AppColors.selectionBlueLight;
  static Color borderColorSelected = AppColors.selectionBlueDark;
  static Color textColorSelected = AppColors.eel;

  // Correct state colors
  static Color backgroundColorCorrect = AppColors.correctGreenLight;
  static Color borderColorCorrect = AppColors.correctGreenDark;
  static Color textColorCorrect = AppColors.eel;

  // Incorrect state colors
  static Color backgroundColorIncorrect = AppColors.incorrectRedLight;
  static Color borderColorIncorrect = AppColors.incorrectRedDark;
  static Color textColorIncorrect = AppColors.eel;
}
