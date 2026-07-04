import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/core/app_preferences.dart';
import 'package:vocabu_rex_mobile/home/ui/widgets/aurora_map_background.dart';

class StaticSpaceBackground extends StatelessWidget {
  final Widget? child;
  final Color primaryColor;
  final Color secondaryColor;

  const StaticSpaceBackground({
    super.key,
    this.child,
    this.primaryColor = AppColors.macaw,
    this.secondaryColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppPreferences().isDarkMode;
    final baseColor = isDark ? AppColors.background : AppColors.snow;

    return Container(
      color: baseColor,
      child: Stack(
        children: [
          // Lớp 1: Mesh Gradient (Aurora) tĩnh
          Positioned.fill(
            child: CustomPaint(
              size: Size.infinite,
              painter: AuroraPainter(
                time: 2.0, // Cố định thời gian để lấy 1 khoảnh khắc gradient đẹp
                primaryColor: primaryColor,
                secondaryColor: secondaryColor.withOpacity(0.5),
                isDark: isDark,
              ),
            ),
          ),
          
          // Lớp 2: Backdrop Filter mờ để trộn Gradient (Glassmorphism effect)
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(
                  color: baseColor.withOpacity(isDark ? 0.6 : 0.4),
                ),
              ),
            ),
          ),

          // Lớp 3: Content bên trên
          if (child != null)
            Positioned.fill(child: child!),
        ],
      ),
    );
  }
}
