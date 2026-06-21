import os

file_path = r"c:\TLCN\vocabu_rex_mobile\lib\home\ui\widgets\skill_divider.dart"

new_code = """import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'dart:math' as math;
import 'package:vocabu_rex_mobile/core/app_preferences.dart';

/// Widget divider với title giữa các skills
/// Có hiệu ứng bắn năng lượng/tia lửa từ chữ ra 2 bên
class SkillDivider extends StatefulWidget {
  final String title;
  final Color? color;

  const SkillDivider({super.key, required this.title, this.color});

  @override
  State<SkillDivider> createState() => _SkillDividerState();
}

class _SkillDividerState extends State<SkillDivider> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 1500)
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = widget.color ?? AppColors.primary;
    final isDark = AppPreferences().isDarkMode;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 24,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: EnergyBeamPainter(
                      color: themeColor,
                      time: _controller.value,
                      isLeft: true,
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: (isDark ? Colors.black : Colors.white).withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: themeColor.withOpacity(0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: themeColor.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ]
              ),
              child: Text(
                widget.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: themeColor,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
          Expanded(
            child: SizedBox(
              height: 24,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: EnergyBeamPainter(
                      color: themeColor,
                      time: _controller.value,
                      isLeft: false,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EnergyBeamPainter extends CustomPainter {
  final Color color;
  final double time;
  final bool isLeft;

  EnergyBeamPainter({
    required this.color,
    required this.time,
    required this.isLeft,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(color.value);
    
    // Draw faint core beam
    final beamRect = Rect.fromLTWH(0, size.height / 2 - 0.5, size.width, 1);
    final gradient = LinearGradient(
      colors: isLeft 
        ? [Colors.transparent, color.withOpacity(0.6)] 
        : [color.withOpacity(0.6), Colors.transparent],
    );
    final beamPaint = Paint()..shader = gradient.createShader(beamRect);
    canvas.drawRect(beamRect, beamPaint);

    // Draw shooting particles (fire/energy bursts)
    for (int i = 0; i < 6; i++) {
      double pTime = (time + i * 0.16) % 1.0;
      
      // Calculate X position moving OUTWARD from center
      double startX = isLeft ? size.width : 0;
      double endX = isLeft ? 0 : size.width;
      
      // Easing out curve so it shoots fast then slows down
      double easedTime = 1.0 - math.pow(1.0 - pTime, 3).toDouble();
      double currentX = startX + (endX - startX) * easedTime;
      
      // Wave motion for Y
      double amplitude = (random.nextDouble() * 16 - 8) * math.sin(pTime * math.pi);
      double currentY = size.height / 2 + amplitude;
      
      // Fade out as it reaches the end
      double opacity = math.sin(pTime * math.pi);
      if (opacity < 0) opacity = 0;

      final pGlow = Paint()
        ..color = color.withOpacity(opacity * 0.8)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      final pCore = Paint()
        ..color = Colors.white.withOpacity(opacity * 0.9)
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round;

      double trailLength = 20.0 * (1.0 - pTime);
      double dx = isLeft ? trailLength : -trailLength;
      
      canvas.drawLine(
        Offset(currentX, currentY), 
        Offset(currentX + dx, currentY), 
        pGlow
      );
      canvas.drawLine(
        Offset(currentX, currentY), 
        Offset(currentX + dx, currentY), 
        pCore
      );
    }
  }

  @override
  bool shouldRepaint(covariant EnergyBeamPainter oldDelegate) {
    return oldDelegate.time != time || 
           oldDelegate.color != color || 
           oldDelegate.isLeft != isLeft;
  }
}
"""

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(new_code)

print("SkillDivider updated with animated energy beams.")
