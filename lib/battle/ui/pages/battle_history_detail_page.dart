import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:vocabu_rex_mobile/battle/domain/entities/battle_entities.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/core/app_preferences.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shimmer/shimmer.dart';

class BattleHistoryDetailPage extends StatefulWidget {
  final BattleHistoryEntity match;

  const BattleHistoryDetailPage({super.key, required this.match});

  @override
  State<BattleHistoryDetailPage> createState() => _BattleHistoryDetailPageState();
}

class _BattleHistoryDetailPageState extends State<BattleHistoryDetailPage> with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  
  // Pseudo-random stats for radar chart based on scores
  late List<double> _myStats;
  late List<double> _oppStats;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    // Generate mock stats based on score
    _myStats = _generateStats(widget.match.myScore, widget.match.opponentScore, true);
    _oppStats = _generateStats(widget.match.opponentScore, widget.match.myScore, false);
  }

  List<double> _generateStats(int myScore, int oppScore, bool isMe) {
    final rand = Random(myScore + oppScore + (isMe ? 1 : 0));
    final base = (myScore / (max(myScore + oppScore, 1))) * 0.5 + 0.3; // 0.3 -> 0.8
    return [
      (base + rand.nextDouble() * 0.4).clamp(0.2, 1.0), // Speed
      (base + rand.nextDouble() * 0.4).clamp(0.2, 1.0), // Damage
      (base + rand.nextDouble() * 0.4).clamp(0.2, 1.0), // Accuracy
      (base + rand.nextDouble() * 0.4).clamp(0.2, 1.0), // Combo
    ];
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppPreferences(),
      builder: (context, _) {
        final isDark = AppPreferences().isDarkMode;
        final isWin = widget.match.result == 'WIN';
        final isDraw = widget.match.result == 'DRAW';
        final mainColor = isWin ? AppColors.featherGreen : (isDraw ? AppColors.bee : AppColors.cardinal);
        final opponentName = widget.match.opponent?.displayName ?? (widget.match.isBot ? 'Bot' : 'Không rõ');

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF0F0F16) : AppColors.polar,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: isDark ? Colors.white : AppColors.bodyText),
            title: Text(
              'Chi Tiết Trận Đấu',
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.bodyText,
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Column(
              children: [
                // Holographic Ticket
                ZoomIn(
                  duration: const Duration(milliseconds: 600),
                  child: _buildHolographicTicket(mainColor, opponentName, isDark),
                ),
            
            SizedBox(height: 40.h),
            
            // Radar Chart Section
            Text(
              'SO GĂNG CHỈ SỐ',
              style: TextStyle(
                color: isDark ? Colors.white70 : AppColors.wolf,
                fontSize: 14.sp,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              height: 250.h,
              child: FadeInLeft(
                delay: const Duration(milliseconds: 200),
                duration: const Duration(milliseconds: 600),
                child: AnimatedBuilder(
                  animation: _animCtrl,
                  builder: (context, child) {
                    return CustomPaint(
                      size: Size.infinite,
                      painter: RadarChartPainter(
                        myStats: _myStats.map((e) => e * _animCtrl.value).toList(),
                        oppStats: _oppStats.map((e) => e * _animCtrl.value).toList(),
                        myColor: AppColors.macaw,
                        oppColor: AppColors.cardinal,
                        isDark: isDark,
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 30.h),
            
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Bạn', AppColors.macaw, isDark),
                SizedBox(width: 24.w),
                _buildLegendItem(opponentName, AppColors.cardinal, isDark),
              ],
            ),
            
            SizedBox(height: 40.h),
            
            // Action Buttons
            if (isWin)
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                duration: const Duration(milliseconds: 500),
                child: _buildActionButton('KHOE CHIẾN TÍCH', Icons.share, AppColors.featherGreen),
              )
            else if (!isDraw)
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                duration: const Duration(milliseconds: 500),
                child: _buildActionButton('PHỤC HẬN', Icons.refresh, AppColors.cardinal),
              ),
              
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
      },
    );
  }

  Widget _buildLegendItem(String name, Color color, bool isDark) {
    return Row(
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 8.w),
        Text(
          name,
          style: TextStyle(color: isDark ? Colors.white : AppColors.bodyText, fontSize: 12.sp, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildActionButton(String text, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      height: 56.h,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 15),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // TODO: Implement share/rematch
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Tính năng đang được phát triển!')),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24.sp),
              SizedBox(width: 8.w),
              Text(
                text,
                style: TextStyle(
                  color: color,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHolographicTicket(Color mainColor, String opponentName, bool isDark) {
    final dateStr = widget.match.completedAt != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(widget.match.completedAt!)
        : '--';

    return AnimatedBuilder(
      animation: _animCtrl,
      builder: (context, child) {
        // Tạo hiệu ứng trôi nổi nhẹ
        final dy = sin(_animCtrl.value * pi * 2) * 10;
        
        return Transform.translate(
          offset: Offset(0, dy),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark ? [
                  const Color(0xFF1E1E2E),
                  mainColor.withValues(alpha: 0.2),
                  const Color(0xFF1E1E2E),
                ] : [
                  AppColors.snow,
                  mainColor.withValues(alpha: 0.1),
                  AppColors.snow,
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: mainColor.withValues(alpha: 0.5), width: 2),
              boxShadow: [
                BoxShadow(color: mainColor.withValues(alpha: 0.2), blurRadius: 30, spreadRadius: 5),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  children: [
                    Text(
                      'BATTLE TICKET',
                      style: TextStyle(
                        color: isDark ? Colors.white30 : AppColors.wolf.withValues(alpha: 0.5),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildPlayerSide('BẠN', widget.match.myScore, AppColors.macaw, isDark),
                        Text(
                          'VS',
                          style: TextStyle(
                            color: isDark ? Colors.white : AppColors.bodyText,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        _buildPlayerSide(opponentName, widget.match.opponentScore, AppColors.cardinal, isDark),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    Divider(color: isDark ? Colors.white12 : AppColors.swan, thickness: 2),
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('THỜI GIAN', style: TextStyle(color: isDark ? Colors.white54 : AppColors.hare, fontSize: 10.sp)),
                            SizedBox(height: 4.h),
                            Text(dateStr, style: TextStyle(color: isDark ? Colors.white : AppColors.bodyText, fontSize: 12.sp, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        if (widget.match.xpEarned > 0)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('PHẦN THƯỞNG', style: TextStyle(color: isDark ? Colors.white54 : AppColors.hare, fontSize: 10.sp)),
                              SizedBox(height: 4.h),
                              Text('+${widget.match.xpEarned} XP', style: TextStyle(color: AppColors.bee, fontSize: 14.sp, fontWeight: FontWeight.w900)),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
                // Stamp
                Positioned(
                  right: -20,
                  top: 20,
                  child: Transform.rotate(
                    angle: pi / 6,
                    child: Opacity(
                      opacity: _animCtrl.value.clamp(0.0, 1.0),
                      child: Transform.scale(
                        scale: 2.0 - _animCtrl.value, // Pop in effect
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            border: Border.all(color: mainColor, width: 4),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Shimmer.fromColors(
                            baseColor: mainColor,
                            highlightColor: Colors.white,
                            period: const Duration(seconds: 2),
                            child: Text(
                              widget.match.result,
                              style: TextStyle(
                                color: mainColor,
                                fontSize: 28.sp,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayerSide(String name, int score, Color color, bool isDark) {
    return Column(
      children: [
        Container(
          width: 60.w,
          height: 60.w,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(color: isDark ? Colors.white : AppColors.bodyText, fontSize: 24.sp, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          width: 80.w,
          child: Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: isDark ? Colors.white70 : AppColors.wolf, fontSize: 12.sp, fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          score.toString(),
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.bodyText,
            fontSize: 24.sp,
            fontWeight: FontWeight.w900,
            fontFamily: 'DuolingoFeather',
          ),
        ),
      ],
    );
  }
}

// Custom Painter for Radar Chart
class RadarChartPainter extends CustomPainter {
  final List<double> myStats; // [Speed, Damage, Accuracy, Combo]
  final List<double> oppStats;
  final Color myColor;
  final Color oppColor;
  final bool isDark;
  final List<String> labels = ['Tốc Độ', 'Sát Thương', 'Chính Xác', 'Combo'];

  RadarChartPainter({
    required this.myStats,
    required this.oppStats,
    required this.myColor,
    required this.oppColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = min(size.width / 2, size.height / 2) - 20; // 20 padding for labels
    final angleStep = (2 * pi) / 4;

    // Draw background grid
    final gridPaint = Paint()
      ..color = isDark ? Colors.white24 : AppColors.swan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 1; i <= 4; i++) {
      final r = maxRadius * (i / 4);
      final path = Path();
      for (int j = 0; j < 4; j++) {
        final x = center.dx + r * cos(j * angleStep - pi / 2);
        final y = center.dy + r * sin(j * angleStep - pi / 2);
        if (j == 0) path.moveTo(x, y);
        else path.lineTo(x, y);
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    // Draw axes & labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int j = 0; j < 4; j++) {
      final x = center.dx + maxRadius * cos(j * angleStep - pi / 2);
      final y = center.dy + maxRadius * sin(j * angleStep - pi / 2);
      canvas.drawLine(center, Offset(x, y), gridPaint);

      // Draw label
      final labelX = center.dx + (maxRadius + 15) * cos(j * angleStep - pi / 2);
      final labelY = center.dy + (maxRadius + 15) * sin(j * angleStep - pi / 2);
      
      textPainter.text = TextSpan(
        text: labels[j],
        style: TextStyle(color: isDark ? Colors.white70 : AppColors.wolf, fontSize: 10.sp, fontWeight: FontWeight.bold),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(labelX - textPainter.width / 2, labelY - textPainter.height / 2),
      );
    }

    // Draw Opponent Stats Polygon
    _drawPolygon(canvas, center, maxRadius, angleStep, oppStats, oppColor);
    
    // Draw My Stats Polygon
    _drawPolygon(canvas, center, maxRadius, angleStep, myStats, myColor);
  }

  void _drawPolygon(Canvas canvas, Offset center, double maxRadius, double angleStep, List<double> stats, Color color) {
    final path = Path();
    for (int j = 0; j < 4; j++) {
      final r = maxRadius * stats[j];
      final x = center.dx + r * cos(j * angleStep - pi / 2);
      final y = center.dy + r * sin(j * angleStep - pi / 2);
      if (j == 0) path.moveTo(x, y);
      else path.lineTo(x, y);
    }
    path.close();

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant RadarChartPainter oldDelegate) {
    return true; // Always repaint for animation
  }
}
