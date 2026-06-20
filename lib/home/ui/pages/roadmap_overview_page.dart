import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/skill_part_entity.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/typography.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:ui';

class RoadCurvePainter extends CustomPainter {
  final double startX;
  final double endX;
  final Color color;
  final bool isDashed;

  RoadCurvePainter({
    required this.startX,
    required this.endX,
    required this.color,
    this.isDashed = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    Path path = Path();
    path.moveTo(startX, 0);
    path.cubicTo(
      startX,
      size.height / 2,
      endX,
      size.height / 2,
      endX,
      size.height,
    );

    if (isDashed) {
      Path dashPath = Path();
      const double dashLength = 15.0;
      const double dashSpace = 10.0;

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
    } else {
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant RoadCurvePainter oldDelegate) {
    return oldDelegate.startX != startX ||
        oldDelegate.endX != endX ||
        oldDelegate.color != color ||
        oldDelegate.isDashed != isDashed;
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
    // Determine the current milestone index
    int currentIndex = milestones.indexWhere(
      (m) => m.skills?.any((s) => s.id == currentSkillId) ?? false,
    );
    if (currentIndex == -1) currentIndex = 0; // Fallback

    return Scaffold(
      backgroundColor: AppColors.polar, // Subtle background
      appBar: AppBar(
        backgroundColor: AppColors.polar,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: AppColors.bodyText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Hành trình',
          style:
              AppTypography.defaultTextTheme(AppColors.bodyText).titleLarge?.copyWith(
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

          final isCurrent = index == currentIndex;
          final isCompleted = index < currentIndex;
          final isLocked = index > currentIndex;

          final bool isEven = index % 2 == 0;
          final double leftX = 70.0;
          final double rightX = 130.0;

          final double currentX = isEven ? leftX : rightX;
          final double nextX = isEven ? rightX : leftX;

          // Configure Node Appearance
          IconData iconData;
          Color nodeColor;
          Color iconColor = AppColors.white;

          if (isCompleted) {
            iconData = Icons.check_rounded;
            nodeColor = AppColors.macaw;
          } else if (isCurrent) {
            iconData = Icons.star_rounded;
            nodeColor = Colors.amber;
          } else {
            iconData = Icons.lock_rounded;
            nodeColor = AppColors.swan;
          }

          Widget iconContainer = Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: nodeColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: nodeColor.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
              border:
                  isCurrent ? Border.all(color: AppColors.white, width: 4) : null,
            ),
            child: Icon(iconData, color: iconColor, size: 32),
          );

          if (isCurrent) {
            iconContainer = Pulse(
              infinite: true,
              child: iconContainer,
            );
          }

          // Road coloring
          final Color pathColor =
              isCompleted ? AppColors.macaw : AppColors.swan.withOpacity(0.5);
          final bool isPathDashed = !isCompleted;

          return FadeInUp(
            delay: Duration(milliseconds: index * 100),
            duration: const Duration(milliseconds: 600),
            child: SizedBox(
              height: 140, // Increased height for thicker road
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  if (!isLast)
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 64, // roughly bottom of the icon
                      height: 108, // down to the next icon
                      child: FadeIn(
                        delay: Duration(milliseconds: index * 100),
                        child: CustomPaint(
                          painter: RoadCurvePainter(
                            startX: currentX,
                            endX: nextX,
                            color: pathColor,
                            isDashed: isPathDashed,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    left: currentX - 28, // center the 56x56 container
                    top: 8, // top padding for icon area
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        iconContainer,
                        const SizedBox(width: 20),
                        Container(
                          width: MediaQuery.of(context).size.width - currentX - 70,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.bodyText.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: isCurrent
                                  ? Colors.amber.shade300
                                  : AppColors.polar,
                              width: isCurrent ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isCurrent)
                                Text(
                                  'ĐANG HỌC',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber.shade700,
                                    letterSpacing: 1,
                                  ),
                                ),
                              if (isCurrent) const SizedBox(height: 4),
                              Text(
                                milestone.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isCurrent
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  color: isLocked
                                      ? AppColors.hare
                                      : AppColors.bodyText,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
