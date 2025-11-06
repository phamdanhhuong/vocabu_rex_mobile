import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

/// Audio speaker buttons - normal and slow speed with custom styling
class AudioSpeakerButtons extends StatelessWidget {
  final bool isPlayingNormal;
  final bool isPlayingSlow;
  final VoidCallback onPlayNormal;
  final VoidCallback onPlaySlow;

  const AudioSpeakerButtons({
    Key? key,
    required this.isPlayingNormal,
    required this.isPlayingSlow,
    required this.onPlayNormal,
    required this.onPlaySlow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Normal speed button - larger rounded square with speaker icon
        _buildSpeakerButton(
          icon: Icons.volume_up,
          isPlaying: isPlayingNormal,
          onPressed: onPlayNormal,
          size: 80.w,
          borderRadius: 20.r,
        ),
        
        SizedBox(width: 24.w),
        
        // Slow speed button - smaller rounded square with turtle
        _buildSpeakerButton(
          icon: Icons.pets, // Turtle icon
          isPlaying: isPlayingSlow,
          onPressed: onPlaySlow,
          size: 64.w,
          borderRadius: 16.r,
          iconColor: Colors.white,
          backgroundColor: AppColors.selectionBlueLight,
        ),
      ],
    );
  }

  Widget _buildSpeakerButton({
    required IconData icon,
    required bool isPlaying,
    required VoidCallback onPressed,
    required double size,
    required double borderRadius,
    Color? iconColor,
    Color? backgroundColor,
  }) {
    final effectiveBgColor = backgroundColor ?? 
        (isPlaying ? AppColors.selectionBlueLight : Color(0xFF1CB0F6));
    
    return Material(
      color: effectiveBgColor,
      borderRadius: BorderRadius.circular(borderRadius),
      elevation: isPlaying ? 0 : 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: onPressed,
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: size * 0.45,
            color: iconColor ?? Colors.white,
          ),
        ),
      ),
    );
  }
}
