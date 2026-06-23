import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/skill_part_entity.dart';
import 'package:vocabu_rex_mobile/home/ui/blocs/home_bloc.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/typography.dart';
import 'package:animate_do/animate_do.dart';
import 'package:vocabu_rex_mobile/home/ui/widgets/generate_roadmap_form.dart';
import 'package:vocabu_rex_mobile/home/ui/pages/roadmap_history_page.dart';
import 'package:vocabu_rex_mobile/core/app_preferences.dart';

class SpiralGalaxyPainter extends CustomPainter {
  final ui.Picture? backgroundPicture;
  final ui.Picture? armsPicture;
  final double rotationPhase;

  SpiralGalaxyPainter({
    required this.backgroundPicture,
    required this.armsPicture,
    required this.rotationPhase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (backgroundPicture == null || armsPicture == null) return;

    final center = Offset(size.width / 2, size.height / 2);

    // Draw slow-rotating background stars
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationPhase * math.pi * 2 * 0.5); // Parallax effect
    canvas.translate(-center.dx, -center.dy);
    canvas.drawPicture(backgroundPicture!);
    canvas.restore();

    // Draw main spiral arms
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationPhase * math.pi * 2);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawPicture(armsPicture!);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant SpiralGalaxyPainter oldDelegate) => 
      oldDelegate.rotationPhase != rotationPhase || 
      oldDelegate.backgroundPicture != backgroundPicture ||
      oldDelegate.armsPicture != armsPicture;
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

class _RoadmapOverviewPageState extends State<RoadmapOverviewPage> with TickerProviderStateMixin {
  late AnimationController _twinkleController;
  late AnimationController _cameraController;
  late AnimationController _rotationController;
  final TransformationController _transformationController = TransformationController();
  bool _hasScrolled = false;
  final double galaxySize = 2000.0;

  ui.Picture? _backgroundPicture;
  ui.Picture? _armsPicture;

  @override
  void initState() {
    super.initState();
    
    _generateGalaxyPictures();
    _twinkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    
    _cameraController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 120),
    )..repeat();
  }

  @override
  void dispose() {
    _twinkleController.dispose();
    _cameraController.dispose();
    _rotationController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _generateGalaxyPictures() {
    final bool isDark = AppPreferences().isDarkMode;
    final size = Size(galaxySize, galaxySize);
    final center = Offset(size.width / 2, size.height / 2);
    final random = math.Random(42);
    final double maxRadius = size.width / 2 * 0.95;

    // --- Record Background Layer ---
    final ui.PictureRecorder bgRecorder = ui.PictureRecorder();
    final Canvas bgCanvas = Canvas(bgRecorder);
    final Paint bgPaint = Paint()..style = PaintingStyle.fill;

    final int backgroundStars = 8000;
    for (int i = 0; i < backgroundStars; i++) {
      final double distance = math.pow(random.nextDouble(), 0.8) * maxRadius;
      final double theta = random.nextDouble() * math.pi * 2;
      final double x = center.dx + distance * math.cos(theta);
      final double y = center.dy + distance * math.sin(theta);
      
      final double opacity = math.max(0.05, 1.0 - (distance / maxRadius)) * 0.5;
      final double starSize = random.nextDouble() * 1.5;
      
      bgPaint.color = (isDark ? Colors.white : AppColors.macaw).withOpacity(opacity.clamp(0.0, 1.0));
      bgCanvas.drawCircle(Offset(x, y), starSize, bgPaint);
    }
    _backgroundPicture = bgRecorder.endRecording();

    // --- Record Arms Layer ---
    final ui.PictureRecorder armsRecorder = ui.PictureRecorder();
    final Canvas armsCanvas = Canvas(armsRecorder);
    final Paint armsPaint = Paint()..style = PaintingStyle.fill;

    // Core Glow
    final Rect coreRect = Rect.fromCircle(center: center, radius: 250);
    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          (isDark ? Colors.white : AppColors.macaw).withOpacity(0.8),
          (isDark ? Colors.white : AppColors.macaw).withOpacity(0.0),
        ],
      ).createShader(coreRect);
    armsCanvas.drawCircle(center, 250, corePaint);

    final int numArms = 5;
    final int starsPerArm = 2000;

    for (int i = 0; i < numArms; i++) {
      final double armOffset = (math.pi * 2 / numArms) * i;
      for (int j = 0; j < starsPerArm; j++) {
        final double distance = math.pow(random.nextDouble(), 1.5) * maxRadius;
        final double theta = distance * 0.005 + armOffset;

        final double armThickness = 40.0 + (distance * 0.1); 
        final double scatter = (random.nextDouble() - 0.5) * armThickness;
        final double finalTheta = theta + (random.nextDouble() - 0.5) * 0.1;
        final double finalRadius = distance + scatter;

        final double x = center.dx + finalRadius * math.cos(finalTheta);
        final double y = center.dy + finalRadius * math.sin(finalTheta);

        final double opacity = math.max(0.05, 1.0 - (distance / maxRadius)) * 0.8;
        final double starSize = random.nextDouble() * 3.0 + 0.5;

        armsPaint.color = (isDark ? Colors.white : AppColors.macaw)
            .withOpacity(opacity.clamp(0.0, 1.0));

        armsCanvas.drawCircle(Offset(x, y), starSize, armsPaint);
      }
    }
    _armsPicture = armsRecorder.endRecording();
  }

  void _panToCurrentNode(int currentIndex) {
    if (_hasScrolled) return;
    _hasScrolled = true;

    final center = Offset(galaxySize / 2, galaxySize / 2);
    final double maxNodeRadius = 850.0;
    // Path calculation: from edge to core
    // currentIndex: 0 is at edge (850), last index is at core (100)
    // We assume around 15-20 total milestones on average for scaling, or we just dynamically scale.
    // Let's use 100 distance step backwards.
    final double distance = math.max(100.0, maxNodeRadius - (currentIndex * 60.0));
    final int armIndex = currentIndex % 5;
    final double armOffset = (math.pi * 2 / 5) * armIndex;
    
    // Predict theta based on current rotation to center properly
    final double theta = distance * 0.005 + armOffset + (_rotationController.value * math.pi * 2);
    final double nodeX = center.dx + distance * math.cos(theta);
    final double nodeY = center.dy + distance * math.sin(theta);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;
      
      final double targetScale = 1.0;
      final x = nodeX * targetScale - screenWidth / 2;
      final y = nodeY * targetScale - screenHeight / 2;

      // Start completely zoomed out (center of galaxy)
      final Matrix4 startMatrix = Matrix4.identity()
        ..translate(-(center.dx * 0.1 - screenWidth / 2), -(center.dy * 0.1 - screenHeight / 2))
        ..scale(0.1);

      _transformationController.value = startMatrix;

      final Matrix4 endMatrix = Matrix4.identity()
        ..translate(-x, -y)
        ..scale(targetScale);

      Animation<Matrix4> animation = Matrix4Tween(
        begin: startMatrix,
        end: endMatrix,
      ).animate(CurvedAnimation(
        parent: _cameraController,
        curve: Curves.easeInOutCubic,
      ));

      animation.addListener(() {
        _transformationController.value = animation.value;
      });

      // Delay a bit before panning to let the Zoom-out transition finish
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) _cameraController.forward();
      });
    });
  }

  void _showConstellationScanner(SkillPartEntity milestone, bool isCurrent, bool isCompleted, bool isDark) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Opacity(
                    opacity: value.clamp(0.0, 1.0),
                    child: child,
                  ),
                );
              },
              child: Container(
                width: 320,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.black : Colors.white).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isCurrent ? AppColors.macaw : AppColors.swan,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isCurrent ? AppColors.macaw.withOpacity(0.3) : AppColors.swan.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isCompleted ? Icons.check_circle : (isCurrent ? Icons.star : Icons.lock),
                              color: isCompleted ? AppColors.macaw : (isCurrent ? Colors.amber : Colors.grey),
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                milestone.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : AppColors.bodyText,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildScannerRow(Icons.analytics, 'Phân tích AI:', isCurrent ? 'Quỹ đạo thích ứng' : 'Chưa phân tích', isDark),
                        const SizedBox(height: 12),
                        _buildScannerRow(Icons.extension, 'Khối lượng:', '${(milestone.skills?.length ?? 1) * 3} tinh thể', isDark),
                        const SizedBox(height: 12),
                        _buildScannerRow(Icons.radar, 'Trạng thái:', isCompleted ? 'Đã thu thập' : (isCurrent ? 'Đang khám phá' : 'Chưa mở khóa'), isDark),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.macaw,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Đóng hệ thống', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Pulse(
                          infinite: true,
                          duration: const Duration(seconds: 2),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  AppColors.macaw.withOpacity(0.1),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildScannerRow(IconData icon, String label, String value, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.hare),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(color: AppColors.hare, fontSize: 14),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: isDark ? Colors.white70 : AppColors.bodyText,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state is HomeUnauthen) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Có lỗi xảy ra khi xem lộ trình')),
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

        _panToCurrentNode(currentIndex);

        final isDark = AppPreferences().isDarkMode;
        final center = Offset(galaxySize / 2, galaxySize / 2);
        
        final List<Color> neonColors = [
          AppColors.macaw,
          AppColors.beetle,
          AppColors.cardinal,
          AppColors.bee,
        ];

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF050510) : const Color(0xFF101525), 
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: (isDark ? Colors.black : const Color(0xFF101525)).withOpacity(0.5),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Đại lộ Ngân Hà',
              style: AppTypography.defaultTextTheme(Colors.white).titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.history, color: Colors.white),
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
                icon: const Icon(Icons.auto_awesome, color: Colors.white),
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
          body: InteractiveViewer(
            transformationController: _transformationController,
            constrained: false,
            boundaryMargin: EdgeInsets.all(galaxySize / 2),
            minScale: 0.05,
            maxScale: 2.0,
            child: SizedBox(
              width: galaxySize,
              height: galaxySize,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: Listenable.merge([_twinkleController, _rotationController]),
                      builder: (context, child) {
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned.fill(
                              child: CustomPaint(
                                painter: SpiralGalaxyPainter(
                                  backgroundPicture: _backgroundPicture,
                                  armsPicture: _armsPicture,
                                  rotationPhase: _rotationController.value,
                                ),
                              ),
                            ),
                            ...displayMilestones.asMap().entries.map((entry) {
                              final int i = entry.key;
                              final milestone = entry.value;
                              
                              final isCurrent = i == currentIndex;
                              final isCompleted = i < currentIndex;
                              final isLocked = i > currentIndex;

                              final double maxNodeRadius = 850.0;
                              final double distance = math.max(100.0, maxNodeRadius - (i * 60.0));
                              final int armIndex = i % 5;
                              final double armOffset = (math.pi * 2 / 5) * armIndex;
                              final double theta = distance * 0.005 + armOffset + (_rotationController.value * math.pi * 2);
                              final double x = center.dx + distance * math.cos(theta);
                              final double y = center.dy + distance * math.sin(theta);

                              IconData iconData = isCompleted ? Icons.check_circle : (isCurrent ? Icons.star : Icons.lock);
                              Color nodeColor = isCompleted 
                                  ? neonColors[i % neonColors.length] 
                                  : (isCurrent ? Colors.amber : AppColors.swan.withOpacity(0.6));

                              Widget nodeWidget = GestureDetector(
                                onTap: () => _showConstellationScanner(milestone, isCurrent, isCompleted, isDark),
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: nodeColor.withOpacity(isLocked ? 0.3 : 0.8),
                                    border: Border.all(color: isCurrent ? Colors.white : nodeColor.withOpacity(0.5), width: isCurrent ? 3 : 1),
                                    boxShadow: [
                                      BoxShadow(color: nodeColor.withOpacity(0.6), blurRadius: 20, spreadRadius: 5),
                                    ],
                                  ),
                                  child: Icon(iconData, color: Colors.white, size: 40),
                                ),
                              );

                              if (isCurrent) {
                                nodeWidget = AnimatedBuilder(
                                  animation: _twinkleController,
                                  builder: (context, child) {
                                    final double phase = _twinkleController.value;
                                    final double flash = math.pow(math.sin(phase * math.pi * 4), 8).toDouble();
                                    return Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.amber.withOpacity(0.4 + flash * 0.6),
                                            blurRadius: 30 + flash * 20,
                                            spreadRadius: 10 + flash * 10,
                                          ),
                                        ],
                                      ),
                                      child: child,
                                    );
                                  },
                                  child: nodeWidget,
                                );
                              }

                              return Positioned(
                                left: x - 40,
                                top: y - 40,
                                child: nodeWidget,
                              );
                            }).toList(),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
