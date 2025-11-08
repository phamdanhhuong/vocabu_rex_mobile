import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

class AudioButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isPlaying;
  final double size;

  const AudioButton({
    super.key,
    required this.onPressed,
    this.isPlaying = false,
    this.size = 80.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size.w,
        height: size.h,
        decoration: BoxDecoration(
          color: AppColors.macaw,
          borderRadius: BorderRadius.circular(size * 0.2),
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            child: isPlaying
                ? Icon(
                    Icons.pause,
                    key: ValueKey('pause'),
                    color: Colors.white,
                    size: (size * 0.5).sp,
                  )
                : Icon(
                    Icons.volume_up,
                    key: ValueKey('sound'),
                    color: Colors.white,
                    size: (size * 0.5).sp,
                  ),
          ),
        ),
      ),
    );
  }
}
