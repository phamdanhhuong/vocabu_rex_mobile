import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/core/app_preferences.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

class PodcastControls extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onSeekBackward;

  const PodcastControls({
    super.key,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onSeekBackward,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppPreferences().isDarkMode;

    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      child: Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isDark ? AppColors.swan : AppColors.polar,
          borderRadius: BorderRadius.circular(40.r),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.3) : AppColors.hare.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: isDark ? AppColors.swan.withOpacity(0.1) : Colors.white,
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Replay current segment
            _buildControlButton(
              icon: Icons.replay_10,
              onPressed: onSeekBackward,
              color: AppColors.wolf,
              isDark: isDark,
            ),

            SizedBox(width: 48.w),

            // Play/Pause
            _buildControlButton(
              icon: isPlaying ? Icons.pause : Icons.play_arrow,
              onPressed: onPlayPause,
              color: AppColors.primary,
              isMain: true,
              isDark: isDark,
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
    bool isMain = false,
    required bool isDark,
  }) {
    final size = isMain ? 56.w : 40.w;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isMain ? color : AppColors.snow,
          shape: BoxShape.circle,
          boxShadow: isMain
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: isDark ? Colors.black.withOpacity(0.2) : AppColors.hare.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Icon(
          icon,
          size: isMain ? 32.sp : 24.sp,
          color: isMain ? AppColors.snow : color,
        ),
      ),
    );
  }
}
