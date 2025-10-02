import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/constants/app_colors.dart';

class DuoCharacterWithSpeech extends StatelessWidget {
  final String message;

  const DuoCharacterWithSpeech({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Speech bubble
        Container(
          margin: EdgeInsets.symmetric(horizontal: 32.w),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            children: [
              Text(
                message,
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 16.sp,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              // Speech bubble tail
              Container(
                margin: EdgeInsets.only(top: 8.h),
                child: CustomPaint(
                  size: Size(20.w, 10.h),
                  painter: SpeechBubbleTailPainter(),
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(height: 16.h),
        
        // Duo character
        _buildDuoCharacter(),
      ],
    );
  }

  Widget _buildDuoCharacter() {
    return Container(
      width: 80.w,
      height: 80.h,
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(40.r),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main body
          Container(
            width: 60.w,
            height: 60.h,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.circular(30.r),
            ),
          ),
          // Eyes
          Positioned(
            top: 20.h,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildEye(),
                SizedBox(width: 8.w),
                _buildEye(),
              ],
            ),
          ),
          // Beak
          Positioned(
            top: 35.h,
            child: Container(
              width: 8.w,
              height: 6.h,
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(3.r),
              ),
            ),
          ),
          // Book
          Positioned(
            bottom: 10.h,
            right: 10.w,
            child: Container(
              width: 16.w,
              height: 12.h,
              decoration: BoxDecoration(
                color: Colors.brown,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          // Pencil
          Positioned(
            bottom: 8.h,
            left: 10.w,
            child: Container(
              width: 3.w,
              height: 14.h,
              decoration: BoxDecoration(
                color: Colors.yellow,
                borderRadius: BorderRadius.circular(1.5.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEye() {
    return Container(
      width: 12.w,
      height: 16.h,
      decoration: BoxDecoration(
        color: AppColors.textWhite,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Container(
        margin: EdgeInsets.only(top: 2.h),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(6.r),
        ),
      ),
    );
  }
}

class SpeechBubbleTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[800]!
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2 - 10, 0);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width / 2 + 10, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}