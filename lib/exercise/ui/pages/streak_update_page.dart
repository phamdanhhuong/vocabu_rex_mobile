import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/exercise/ui/widgets/custom_button.dart';

class StreakUpdatePage extends StatefulWidget {
  final int previousStreak;
  final int newStreak;
  final bool isPerfect;

  const StreakUpdatePage({
    super.key,
    required this.previousStreak,
    required this.newStreak,
    this.isPerfect = false,
  });

  @override
  State<StreakUpdatePage> createState() => _StreakUpdatePageState();
}

class _StreakUpdatePageState extends State<StreakUpdatePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _counterAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _counterAnimation = IntTween(
      begin: widget.previousStreak,
      end: widget.newStreak,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    // Start animation after a brief delay
    Future.delayed(Duration(milliseconds: 300), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final streakIncrement = widget.newStreak - widget.previousStreak;

    return Scaffold(
      backgroundColor: AppColors.polar,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 60),
            // Streak icon/flame
            Icon(
              Icons.local_fire_department_rounded,
              size: 140,
              color: AppColors.fox,
            ),
            SizedBox(height: 24),
            // Title
            Text(
              'STREAK CẬP NHẬT!',
              style: TextStyle(
                color: AppColors.macaw,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 48),
            // Animated counter
            AnimatedBuilder(
              animation: _counterAnimation,
              builder: (context, child) {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${_counterAnimation.value}',
                          style: TextStyle(
                            color: AppColors.fox,
                            fontSize: 80,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                        ),
                        SizedBox(width: 12),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Icon(
                            Icons.local_fire_department,
                            color: AppColors.fox,
                            size: 48,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 16),
            // Increment indicator
            if (streakIncrement > 0)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.featherGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_upward_rounded,
                      color: AppColors.featherGreen,
                      size: 20,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '+$streakIncrement ngày',
                      style: TextStyle(
                        color: AppColors.featherGreen,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 32),
            // Encouragement message
            Container(
              margin: EdgeInsets.symmetric(horizontal: 32),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    widget.isPerfect ? Icons.stars : Icons.celebration,
                    color: AppColors.macaw,
                    size: 32,
                  ),
                  SizedBox(height: 12),
                  Text(
                    _getMessage(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.macaw,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),
            // Continue button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18),
              child: CustomButton(
                color: AppColors.macaw,
                onTap: () {
                  Navigator.of(context).pop(true);
                },
                label: 'TIẾP TỤC',
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMessage() {
    if (widget.isPerfect) {
      return 'Tuyệt vời! Bạn đã hoàn thành bài học hoàn hảo và duy trì streak ${widget.newStreak} ngày!';
    }

    if (widget.newStreak >= 30) {
      return 'Không thể tin nổi! Bạn đã duy trì streak ${widget.newStreak} ngày. Bạn thật kiên trì!';
    } else if (widget.newStreak >= 14) {
      return 'Tuyệt vời! ${widget.newStreak} ngày liên tiếp - bạn đang làm rất tốt!';
    } else if (widget.newStreak >= 7) {
      return 'Thật tuyệt! Bạn đã hoàn thành một tuần liên tiếp!';
    } else if (widget.newStreak >= 3) {
      return 'Tiếp tục phát huy! Streak ${widget.newStreak} ngày của bạn đang tăng lên!';
    } else {
      return 'Khởi đầu tốt! Hãy tiếp tục duy trì nhé!';
    }
  }
}
