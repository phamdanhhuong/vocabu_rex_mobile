import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/skill_part_entity.dart';
import 'package:vocabu_rex_mobile/home/ui/blocs/home_bloc.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/typography.dart';
import 'package:animate_do/animate_do.dart';
import 'package:vocabu_rex_mobile/home/ui/widgets/aurora_map_background.dart';
import 'package:vocabu_rex_mobile/home/ui/widgets/generate_roadmap_form.dart';
import 'package:vocabu_rex_mobile/home/ui/pages/roadmap_history_page.dart';
import 'package:vocabu_rex_mobile/core/app_preferences.dart';
import 'dart:ui';

class RoadCurvePainter extends CustomPainter {
  final double startX;
  final double endX;
  final Color color;
  final bool isDashed;
  final double flowOffset; // For animation

  RoadCurvePainter({
    required this.startX,
    required this.endX,
    required this.color,
    this.isDashed = false,
    this.flowOffset = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Glowing effect
    Paint glowPaint = Paint()
      ..color = color.withOpacity(0.4)
      ..strokeWidth = 32
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

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
      final double patternLength = dashLength + dashSpace;
      
      // Shift start distance based on flowOffset to create animation
      double startDistance = -patternLength + (flowOffset % patternLength);

      for (var metric in path.computeMetrics()) {
        double distance = startDistance;
        while (distance < metric.length) {
          if (distance + dashLength > 0) {
            dashPath.addPath(
              metric.extractPath(
                distance < 0 ? 0 : distance, 
                distance + dashLength
              ),
              Offset.zero,
            );
          }
          distance += patternLength;
        }
      }
      canvas.drawPath(dashPath, glowPaint);
      canvas.drawPath(dashPath, paint);
    } else {
      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant RoadCurvePainter oldDelegate) {
    return oldDelegate.startX != startX ||
        oldDelegate.endX != endX ||
        oldDelegate.color != color ||
        oldDelegate.isDashed != isDashed ||
        oldDelegate.flowOffset != flowOffset;
  }
}

class RoadmapOverviewPage extends StatefulWidget {
  final List<SkillPartEntity> milestones;
  final String currentSkillId;

  const RoadmapOverviewPage({
    super.key,
    required this.milestones,
    required this.currentSkillId,
  });

  @override
  State<RoadmapOverviewPage> createState() => _RoadmapOverviewPageState();
}

class _RoadmapOverviewPageState extends State<RoadmapOverviewPage> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _flowController;

  @override
  void initState() {
    super.initState();
    _flowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _flowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state is HomeUnauthen) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Có lỗi xảy ra khi tạo lộ trình mới')),
          );
        }
      },
      builder: (context, state) {
        List<SkillPartEntity> displayMilestones = widget.milestones;
        if (state is HomeSuccess && state.skillPartEntities != null) {
          displayMilestones = state.skillPartEntities!;
        }

        int currentIndex = displayMilestones.indexWhere(
          (m) => m.skills?.any((s) => s.id == widget.currentSkillId) ?? false,
        );
        if (currentIndex == -1) currentIndex = 0;

    final isDark = AppPreferences().isDarkMode;

    return Scaffold(
      backgroundColor: Colors.transparent, // Background handled by Aurora
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: (isDark ? Colors.black : Colors.white).withOpacity(0.5),
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: isDark ? Colors.white : AppColors.bodyText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Đại lộ Ngân Hà',
          style: AppTypography.defaultTextTheme(isDark ? Colors.white : AppColors.bodyText).titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppColors.bodyText,
          ),
        ),
        actions: [
          if (state is HomeLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: Icon(Icons.history, color: isDark ? Colors.white : AppColors.bodyText),
              tooltip: 'Lịch sử lộ trình',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => const RoadmapHistoryPage(),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.auto_awesome, color: isDark ? Colors.white : AppColors.bodyText),
              tooltip: 'Tạo lộ trình mới',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => const GenerateRoadmapFormDialog(
                    initialLanguage: '',
                    initialProficiency: '',
                    initialGoals: [],
                    initialMinutes: 0,
                  ),
                );
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: AuroraMapBackground(
              scrollController: _scrollController,
              sectionColor: AppColors.macaw,
              sectionShadowColor: Colors.deepPurple,
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(top: 100, bottom: 60),
                itemCount: displayMilestones.length,
                itemBuilder: (context, index) {
                  final milestone = displayMilestones[index];
                  final isLast = index == displayMilestones.length - 1;

                  final isCurrent = index == currentIndex;
                  final isCompleted = index < currentIndex;
                  final isLocked = index > currentIndex;

                  final bool isEven = index % 2 == 0;
                  final double leftX = 70.0;
                  final double rightX = 130.0;

                  final double currentX = isEven ? leftX : rightX;
                  final double nextX = isEven ? rightX : leftX;

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
                    nodeColor = AppColors.swan.withOpacity(0.6);
                  }

                  // Node Icon Container (Glassmorphism)
                  Widget iconContainer = ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: nodeColor.withOpacity(isLocked ? 0.3 : 0.8),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: nodeColor.withOpacity(0.5),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                          border: Border.all(
                            color: isCurrent ? AppColors.white : nodeColor.withOpacity(0.5), 
                            width: isCurrent ? 3 : 1
                          ),
                        ),
                        child: Icon(iconData, color: iconColor, size: 32),
                      ),
                    ),
                  );

                  if (isCurrent) {
                    iconContainer = Pulse(
                      infinite: true,
                      child: iconContainer,
                    );
                  }

                  final Color pathColor = isCompleted ? AppColors.macaw : (isDark ? Colors.white30 : AppColors.swan.withOpacity(0.5));
                  final bool isPathDashed = !isCompleted;

                  return FadeInUp(
                    delay: Duration(milliseconds: (index % 10) * 100),
                    duration: const Duration(milliseconds: 600),
                    child: SizedBox(
                      height: 140,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          if (!isLast)
                            Positioned(
                              left: 0,
                              right: 0,
                              top: 64,
                              height: 108,
                              child: AnimatedBuilder(
                                animation: _flowController,
                                builder: (context, child) {
                                  return CustomPaint(
                                    painter: RoadCurvePainter(
                                      startX: currentX,
                                      endX: nextX,
                                      color: pathColor,
                                      isDashed: isPathDashed,
                                      // Flow downwards
                                      flowOffset: _flowController.value * 25.0,
                                    ),
                                  );
                                },
                              ),
                            ),
                          Positioned(
                            left: currentX - 28,
                            top: 8,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                iconContainer,
                                const SizedBox(width: 20),
                                // Glassmorphism Info Card
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width > 700 
                                          ? 700 - currentX - 70 
                                          : MediaQuery.of(context).size.width - currentX - 70,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 14),
                                      decoration: BoxDecoration(
                                        color: (isDark ? Colors.black : Colors.white).withOpacity(isLocked ? 0.2 : 0.4),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isCurrent
                                              ? Colors.amber.shade300
                                              : (isDark ? Colors.white24 : Colors.white60),
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
                                                color: isDark ? Colors.amber.shade300 : Colors.amber.shade700,
                                                letterSpacing: 1,
                                              ),
                                            ),
                                          if (isCurrent) const SizedBox(height: 4),
                                          Text(
                                            milestone.name,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: isCurrent
                                                  ? FontWeight.w900
                                                  : FontWeight.w700,
                                              color: isLocked
                                                  ? (isDark ? Colors.white54 : AppColors.hare)
                                                  : (isDark ? Colors.white : AppColors.bodyText),
                                              height: 1.3,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
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
            ),
          ),
        ],
      ),
    );
    });
  }
}
