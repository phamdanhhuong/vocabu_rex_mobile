import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

/// Vòng tròn hiển thị trong "Streak bạn bè"
class FriendStreakCircle extends StatelessWidget {
  final Widget child;
  final bool isToday;
  final double size;

  const FriendStreakCircle({
    Key? key,
    required this.child,
    this.isToday = false,
    this.size = 50,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If it's today's circle, keep the filled style. Otherwise draw a dashed circle.
    if (isToday) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.macaw.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.macaw,
            width: 2.w,
          ),
        ),
        child: Center(child: child),
      );
    }

    return _DashedCircle(size: size, color: AppColors.swan, child: child);
  }
}

/// Vẽ vòng tròn với viền đứt đoạn
class _DashedCircle extends StatelessWidget {
  final double size;
  final Widget child;
  final Color color;

  const _DashedCircle({
    Key? key,
    required this.size,
    required this.child,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DashedCirclePainter(color: color),
        child: Center(child: child),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;

  _DashedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const double strokeWidth = 2.0;
    const double dashLength = 6.0;
    const double gapLength = 4.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final circumference = 2 * math.pi * radius;
    final step = dashLength + gapLength;
    final dashCount = (circumference / step).floor().clamp(4, 360);
    final thetaPerDash = 2 * math.pi / dashCount;
    final dashAngle = thetaPerDash * (dashLength / step);

    double startAngle = -math.pi / 2; // start at top
    for (int i = 0; i < dashCount; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        dashAngle,
        false,
        paint,
      );
      startAngle += thetaPerDash;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
