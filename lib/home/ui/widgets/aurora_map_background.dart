import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/core/app_preferences.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

/// Lớp nền Aurora Constellation cho Learning Map với hiệu ứng Parallax.
class AuroraMapBackground extends StatefulWidget {
  final ScrollController scrollController;
  final Color sectionColor;
  final Color? sectionShadowColor;

  const AuroraMapBackground({
    super.key,
    required this.scrollController,
    required this.sectionColor,
    this.sectionShadowColor,
  });

  @override
  State<AuroraMapBackground> createState() => _AuroraMapBackgroundState();
}

class _AuroraMapBackgroundState extends State<AuroraMapBackground> with TickerProviderStateMixin {
  late final AnimationController _auroraController;
  late final AnimationController _particleController;

  double _scrollOffset = 0.0;
  final List<Particle> _particles = [];

  // Để tạo chuyển đổi màu mượt mà khi người dùng cuộn sang Section khác
  Color _currentColor = AppColors.primary;
  Color? _currentShadowColor;
  Color _targetColor = AppColors.primary;
  Color? _targetShadowColor;

  @override
  void initState() {
    super.initState();
    _currentColor = widget.sectionColor;
    _currentShadowColor = widget.sectionShadowColor;
    _targetColor = widget.sectionColor;
    _targetShadowColor = widget.sectionShadowColor;

    _auroraController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    widget.scrollController.addListener(_onScroll);

    // Khởi tạo các hạt (particles)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initParticles();
    });
  }

  void _onScroll() {
    if (!mounted) return;
    setState(() {
      _scrollOffset = widget.scrollController.hasClients ? widget.scrollController.offset : 0.0;
    });
  }

  void _initParticles() {
    final size = MediaQuery.of(context).size;
    final random = math.Random();
    final isDark = AppPreferences().isDarkMode;
    
    // Tùy theo chế độ mà tạo số lượng hạt khác nhau (Stars cho dark, Fireflies cho light)
    final numParticles = isDark ? 60 : 40;

    for (int i = 0; i < numParticles; i++) {
      _particles.add(Particle(
        x: random.nextDouble() * size.width,
        y: random.nextDouble() * size.height * 3, // Dàn trải trên chiều cao ảo lớn hơn màn hình
        size: random.nextDouble() * (isDark ? 3.0 : 4.0) + 1.0,
        speed: random.nextDouble() * 0.5 + 0.1,
        parallaxFactor: random.nextDouble() * 0.8 + 0.2, // Tốc độ trượt khi cuộn
        opacityOffset: random.nextDouble() * math.pi * 2,
        baseOpacity: random.nextDouble() * 0.5 + 0.3,
      ));
    }
  }

  @override
  void didUpdateWidget(covariant AuroraMapBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sectionColor != widget.sectionColor) {
      _targetColor = widget.sectionColor;
      _targetShadowColor = widget.sectionShadowColor;
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    _auroraController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Lerp color smoothly towards target color
    _currentColor = Color.lerp(_currentColor, _targetColor, 0.05) ?? _targetColor;
    if (_targetShadowColor != null) {
      _currentShadowColor = Color.lerp(_currentShadowColor ?? _currentColor, _targetShadowColor, 0.05);
    } else {
      _currentShadowColor = null;
    }

    final isDark = AppPreferences().isDarkMode;
    final baseColor = isDark ? AppColors.background : AppColors.snow;

    return Container(
      color: baseColor,
      child: Stack(
        children: [
          // Lớp 1: Mesh Gradient (Aurora)
          AnimatedBuilder(
            animation: _auroraController,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: AuroraPainter(
                  time: _auroraController.value * math.pi * 2,
                  primaryColor: _currentColor,
                  secondaryColor: _currentShadowColor ?? _currentColor.withOpacity(0.5),
                  isDark: isDark,
                ),
              );
            },
          ),
          
          // Lớp 2: Backdrop Filter mờ để trộn Gradient (Glassmorphism effect)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                color: baseColor.withOpacity(isDark ? 0.6 : 0.4),
              ),
            ),
          ),

          // Lớp 3: Parallax Particles
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: ParticlePainter(
                  particles: _particles,
                  scrollOffset: _scrollOffset,
                  time: _particleController.value * math.pi * 2,
                  isDark: isDark,
                  primaryColor: _currentColor,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class Particle {
  double x, y;
  double size;
  double speed;
  double parallaxFactor;
  double opacityOffset;
  double baseOpacity;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.parallaxFactor,
    required this.opacityOffset,
    required this.baseOpacity,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double scrollOffset;
  final double time;
  final bool isDark;
  final Color primaryColor;

  ParticlePainter({
    required this.particles,
    required this.scrollOffset,
    required this.time,
    required this.isDark,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (particles.isEmpty) return;
    
    final paint = Paint()
      ..style = PaintingStyle.fill;

    for (var p in particles) {
      // Tính toán vị trí Y có kết hợp Parallax
      // Dùng modulo để particle lặp lại khi cuộn vượt quá màn hình
      double effectiveY = (p.y - scrollOffset * p.parallaxFactor) % (size.height * 1.5);
      if (effectiveY < -50) effectiveY += size.height * 1.5;
      
      // Chuyển động lơ lửng nhẹ (Float effect)
      double floatX = math.sin(time * p.speed + p.x) * 10;
      double floatY = math.cos(time * p.speed + p.y) * 10;

      double finalX = (p.x + floatX) % size.width;
      double finalY = effectiveY + floatY;

      // Độ sáng nhấp nháy (Twinkle effect)
      double opacity = p.baseOpacity + math.sin(time * 3 + p.opacityOffset) * 0.3;
      opacity = opacity.clamp(0.0, 1.0);

      if (isDark) {
        // Sao trong Dark mode (Trắng / Xanh nhạt)
        paint.color = Colors.white.withOpacity(opacity);
        paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
      } else {
        // Đom đóm trong Light mode (Ám màu của Section)
        paint.color = primaryColor.withOpacity(opacity * 0.6);
        paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
      }

      canvas.drawCircle(Offset(finalX, finalY), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) {
    return oldDelegate.scrollOffset != scrollOffset || oldDelegate.time != time || oldDelegate.primaryColor != primaryColor;
  }
}

class AuroraPainter extends CustomPainter {
  final double time;
  final Color primaryColor;
  final Color secondaryColor;
  final bool isDark;

  AuroraPainter({
    required this.time,
    required this.primaryColor,
    required this.secondaryColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Vẽ 3-4 đốm màu (Blobs) di chuyển theo quỹ đạo hình sin/cos
    final paint1 = Paint()
      ..color = primaryColor.withOpacity(isDark ? 0.6 : 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);

    final paint2 = Paint()
      ..color = secondaryColor.withOpacity(isDark ? 0.5 : 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);
      
    final paint3 = Paint()
      ..color = (isDark ? AppColors.macaw : AppColors.honey).withOpacity(isDark ? 0.3 : 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 70);

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Blob 1 (To nhất, di chuyển góc trái trên)
    final dx1 = math.sin(time) * 100;
    final dy1 = math.cos(time * 0.8) * 100;
    canvas.drawCircle(Offset(cx - 50 + dx1, cy - 150 + dy1), 180, paint1);

    // Blob 2 (Di chuyển góc phải dưới)
    final dx2 = math.cos(time * 1.2) * 120;
    final dy2 = math.sin(time * 0.9) * 120;
    canvas.drawCircle(Offset(cx + 80 + dx2, cy + 100 + dy2), 150, paint2);

    // Blob 3 (Di chuyển ngang giữa)
    final dx3 = math.sin(time * 0.7 + math.pi) * 150;
    final dy3 = math.cos(time * 1.1) * 80;
    canvas.drawCircle(Offset(cx + dx3, cy + dy3), 200, paint3);
  }

  @override
  bool shouldRepaint(covariant AuroraPainter oldDelegate) {
    return oldDelegate.time != time || 
           oldDelegate.primaryColor != primaryColor || 
           oldDelegate.secondaryColor != secondaryColor;
  }
}
