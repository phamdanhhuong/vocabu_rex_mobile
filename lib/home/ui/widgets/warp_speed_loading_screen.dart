import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/core/app_preferences.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'package:animate_do/animate_do.dart';

class WarpSpeedLoadingScreen extends StatefulWidget {
  const WarpSpeedLoadingScreen({super.key});

  @override
  State<WarpSpeedLoadingScreen> createState() => _WarpSpeedLoadingScreenState();
}

class _WarpSpeedLoadingScreenState extends State<WarpSpeedLoadingScreen> with TickerProviderStateMixin {
  late AnimationController _warpController;
  late AnimationController _textController;
  
  int _textIndex = 0;
  final List<String> _loadingTexts = [
    "Đang khởi động bước nhảy không gian...",
    "Đang đồng bộ dữ liệu hệ thống...",
    "Đang bay với tốc độ ánh sáng...",
    "Chuẩn bị tiến vào trạm không gian..."
  ];

  @override
  void initState() {
    super.initState();
    _warpController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _textIndex = (_textIndex + 1) % _loadingTexts.length;
          });
          _textController.forward(from: 0.0);
        }
      });
    
    _textController.forward();
  }

  @override
  void dispose() {
    _warpController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppPreferences().isDarkMode;
    
    return Scaffold(
      backgroundColor: Colors.black, // Always black for space
      body: Stack(
        children: [
          // Warp Speed Stars Background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _warpController,
              builder: (context, child) {
                return CustomPaint(
                  painter: WarpSpeedPainter(
                    time: _warpController.value,
                  ),
                );
              },
            ),
          ),
          
          // Center UI
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Removed AI Core Icon
                
                // Cycling Text
                AnimatedBuilder(
                  animation: _textController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: math.sin(_textController.value * math.pi), // Fade in and out
                      child: Text(
                        _loadingTexts[_textIndex],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    );
                  }
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class WarpSpeedPainter extends CustomPainter {
  final double time;

  WarpSpeedPainter({required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42); // Fixed seed so stars don't flicker
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.sqrt(math.pow(size.width, 2) + math.pow(size.height, 2)) / 2;

    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 150; i++) {
      // Random angle
      final angle = random.nextDouble() * 2 * math.pi;
      
      // Random initial distance ratio
      final startRatio = random.nextDouble();
      
      // Calculate current distance based on time
      // The speed increases as it gets further (perspective)
      double currentRatio = (startRatio + time * 2) % 1.0;
      double distance = maxRadius * math.pow(currentRatio, 3); // pow(3) for acceleration effect
      
      // Calculate length of the streak (longer as it goes faster)
      double length = 5.0 + distance * 0.15;
      
      final start = Offset(
        center.dx + math.cos(angle) * distance,
        center.dy + math.sin(angle) * distance,
      );
      
      final end = Offset(
        center.dx + math.cos(angle) * (distance + length),
        center.dy + math.sin(angle) * (distance + length),
      );

      // Fade based on distance
      paint.color = Colors.white.withOpacity((currentRatio * 1.5).clamp(0.0, 1.0));
      if (random.nextDouble() > 0.8) {
        paint.color = AppColors.macaw.withOpacity(paint.color.opacity);
      }

      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant WarpSpeedPainter oldDelegate) {
    return oldDelegate.time != time;
  }
}
