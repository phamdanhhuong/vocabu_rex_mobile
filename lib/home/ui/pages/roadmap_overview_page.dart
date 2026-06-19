import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/skill_part_entity.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/typography.dart';
import 'dart:ui';

class DashedCurvePainter extends CustomPainter {
  final double startX;
  final double endX;
  final Color color;

  DashedCurvePainter({required this.startX, required this.endX, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    Path path = Path();
    path.moveTo(startX, 0);
    path.cubicTo(
      startX, size.height / 2,
      endX, size.height / 2,
      endX, size.height,
    );

    Path dashPath = Path();
    const double dashLength = 6.0;
    const double dashSpace = 6.0;

    for (var metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + dashLength),
          Offset.zero,
        );
        distance += dashLength + dashSpace;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant DashedCurvePainter oldDelegate) {
    return oldDelegate.startX != startX || oldDelegate.endX != endX || oldDelegate.color != color;
  }
}

class RoadmapOverviewPage extends StatelessWidget {
  final List<SkillPartEntity> milestones;
  final String currentSkillId;

  const RoadmapOverviewPage({
    super.key,
    required this.milestones,
    required this.currentSkillId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: AppColors.bodyText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Roadmap',
          style: AppTypography.defaultTextTheme(AppColors.bodyText).titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.bodyText,
              ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        itemCount: milestones.length,
        itemBuilder: (context, index) {
          final milestone = milestones[index];
          final isLast = index == milestones.length - 1;
          
          final bool isEven = index % 2 == 0;
          final double leftX = 60.0;
          final double rightX = 160.0;
          
          final double currentX = isEven ? leftX : rightX;
          final double nextX = isEven ? rightX : leftX;

          final bool isCurrent = milestone.skills?.any((s) => s.id == currentSkillId) ?? false;
          
          return SizedBox(
            height: 120,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                if (!isLast)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 56, // roughly bottom of the icon
                    height: 84, // down to the next icon
                    child: CustomPaint(
                      painter: DashedCurvePainter(
                        startX: currentX,
                        endX: nextX,
                        color: Colors.amber.shade300,
                      ),
                    ),
                  ),
                Positioned(
                  left: currentX - 24, // center the 48x48 container
                  top: 8, // top padding for icon area
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isCurrent ? Colors.amber.shade100 : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 32),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: MediaQuery.of(context).size.width - currentX - 60,
                        child: Text(
                          milestone.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                            color: Colors.amber.shade600,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
