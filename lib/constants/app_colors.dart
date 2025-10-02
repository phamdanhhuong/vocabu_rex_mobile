import 'package:flutter/material.dart';

/// Định nghĩa các màu sắc thường dùng trong ứng dụng
class AppColors {
  // Màu nền chính của ứng dụng
  static const Color backgroundColor = Color(0xFF131f24);
  static const Color appBarColor = Color(0xFF0B0E0C);
  static const Color primaryDark = Color(0xFF0F1612);

  // Màu chủ đạo
  static const Color primaryGreen = Colors.lightGreen;
  static const Color primaryBlue = Colors.blue;

  // Màu text
  static const Color textWhite = Colors.white;
  static const Color textWhite70 = Colors.white70;
  static const Color textBlue = Colors.blue;

  // Màu cho Node/Level (Learning Map)
  static const Color nodeReachedPrimary = Color.fromARGB(255, 88, 204, 2);
  static const Color nodeReachedSecondary = Color.fromARGB(255, 70, 163, 2);
  static const Color nodeUnreachedPrimary = Color.fromARGB(255, 55, 70, 79);
  static const Color nodeUnreachedSecondary = Color.fromARGB(255, 44, 56, 63);
  static const Color nodeUnreachedBorder = Color.fromARGB(255, 32, 47, 54);

  // Màu border và divider
  static const Color borderGrey = Colors.grey;
  static const Color borderGreyDark = Color.fromARGB(255, 96, 125, 139);

  // Màu transparent và overlay
  static const Color transparent = Colors.transparent;
  static const Color overlayBlack = Colors.black54;
  static const Color overlayBlack26 = Colors.black26;

  // Màu cho loading
  static const Color loadingWhite = Colors.white;
  static const Color loadingGreen = Colors.lightGreen;
}
