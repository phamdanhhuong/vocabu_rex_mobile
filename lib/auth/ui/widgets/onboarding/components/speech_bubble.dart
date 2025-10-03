import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum SpeechBubbleDirection {
  down,   // Mũi tên hướng xuống (khi nằm trên Duo)
  left,   // Mũi tên hướng trái (khi nằm bên phải Duo)
  right,  // Mũi tên hướng phải (khi nằm bên trái Duo)
}

class SpeechBubble extends StatelessWidget {
  final String text;
  final SpeechBubbleDirection direction;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final TextAlign? textAlign;

  const SpeechBubble({
    super.key,
    required this.text,
    this.direction = SpeechBubbleDirection.down,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.fontWeight,
    this.margin,
    this.padding,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.symmetric(horizontal: 16.w),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            padding: padding ?? EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.grey[800],
              borderRadius: BorderRadius.circular(20.w),
            ),
            child: Text(
              text,
              style: TextStyle(
                color: textColor ?? Colors.white,
                fontSize: fontSize ?? 16.sp,
                fontWeight: fontWeight ?? FontWeight.w600,
                height: 1.3,
              ),
              textAlign: textAlign ?? TextAlign.center,
            ),
          ),
          // Triangle pointer based on direction
          _buildTrianglePointer(),
        ],
      ),
    );
  }

  Widget _buildTrianglePointer() {
    switch (direction) {
      case SpeechBubbleDirection.down:
        return Positioned(
          top: -8.h,
          left: 40.w,
          child: CustomPaint(
            painter: TrianglePainter(
              color: backgroundColor ?? Colors.grey[800]!,
              direction: TriangleDirection.down,
            ),
            size: Size(16.w, 8.h),
          ),
        );
      case SpeechBubbleDirection.left:
        return Positioned(
          right: -8.w,
          top: 20.h,
          child: CustomPaint(
            painter: TrianglePainter(
              color: backgroundColor ?? Colors.grey[800]!,
              direction: TriangleDirection.left,
            ),
            size: Size(8.w, 16.h),
          ),
        );
      case SpeechBubbleDirection.right:
        return Positioned(
          left: -8.w,
          top: 20.h,
          child: CustomPaint(
            painter: TrianglePainter(
              color: backgroundColor ?? Colors.grey[800]!,
              direction: TriangleDirection.right,
            ),
            size: Size(8.w, 16.h),
          ),
        );
    }
  }
}

enum TriangleDirection {
  down,
  left,
  right,
}

class TrianglePainter extends CustomPainter {
  final Color color;
  final TriangleDirection direction;

  TrianglePainter({
    required this.color,
    required this.direction,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    switch (direction) {
      case TriangleDirection.down:
        // Triangle pointing down (for speech bubble above)
        path.moveTo(0, size.height);
        path.lineTo(size.width / 2, 0);
        path.lineTo(size.width, size.height);
        break;
      case TriangleDirection.left:
        // Triangle pointing left (for speech bubble on right)
        path.moveTo(size.width, 0);
        path.lineTo(0, size.height / 2);
        path.lineTo(size.width, size.height);
        break;
      case TriangleDirection.right:
        // Triangle pointing right (for speech bubble on left)
        path.moveTo(0, 0);
        path.lineTo(size.width, size.height / 2);
        path.lineTo(0, size.height);
        break;
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}