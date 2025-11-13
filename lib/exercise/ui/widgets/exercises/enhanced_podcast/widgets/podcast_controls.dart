import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

/// Control buttons section for podcast player
/// Simple controls: Replay current segment | Play/Pause | Skip to next segment
class PodcastControls extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onSeekBackward;
  final VoidCallback onSeekForward;

  const PodcastControls({
    super.key,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onSeekBackward,
    required this.onSeekForward,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.snow,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Replay current segment
          _buildControlButton(
            icon: Icons.replay,
            onPressed: onSeekBackward,
            color: AppColors.wolf,
            label: 'Replay',
          ),

          SizedBox(width: 40.w),

          // Play/Pause
          _buildControlButton(
            icon: isPlaying ? Icons.pause : Icons.play_arrow,
            onPressed: onPlayPause,
            color: AppColors.primary,
            size: 64.sp,
            isMain: true,
          ),

          SizedBox(width: 40.w),

          // Skip to next segment
          _buildControlButton(
            icon: Icons.skip_next,
            onPressed: onSeekForward,
            color: AppColors.wolf,
            label: 'Next',
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
    double? size,
    bool isMain = false,
    String? label,
  }) {
    final iconSize = size ?? 32.sp;

    final button = GestureDetector(
      onTap: onPressed,
      child: Container(
        width: isMain ? 64.w : 48.w,
        height: isMain ? 64.h : 48.h,
        decoration: BoxDecoration(
          color: isMain ? color : color.withOpacity(0.1),
          shape: BoxShape.circle,
          boxShadow: isMain
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: iconSize,
          color: isMain ? AppColors.snow : color,
        ),
      ),
    );

    if (label != null && !isMain) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          button,
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: AppColors.wolf,
            ),
          ),
        ],
      );
    }

    return button;
  }
}
