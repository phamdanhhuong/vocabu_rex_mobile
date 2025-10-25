import 'dart:async'; // Thêm thư viện 'async' để dùng Timer
import 'package:flutter/material.dart';
import '../../colors.dart'; // Đảm bảo đường dẫn này chính xác
import 'app_progress_tokens.dart';

/// Hiển thị thanh tiến độ bài học và thông báo streak (chuỗi câu đúng).
class LessonProgressBar extends StatefulWidget { // SỬA ĐỔI: Chuyển sang StatefulWidget
  /// Giá trị tiến độ, từ 0.0 (0%) đến 1.0 (100%).
  final double progress;

  /// Số câu trả lời đúng liên tiếp hiện tại.
  final int streakCount;

  const LessonProgressBar({
    Key? key,
    required this.progress,
    this.streakCount = 0,
  }) : super(key: key);

  @override
  State<LessonProgressBar> createState() => _LessonProgressBarState();
}

// THÊM MỚI: Tạo lớp State
class _LessonProgressBarState extends State<LessonProgressBar> {
  Timer? _streakTimer;
  bool _showStreakMessage = false;

  @override
  void initState() {
    super.initState();
    // Kiểm tra ngay khi widget được tạo lần đầu
    if (widget.streakCount >= 2) {
      _showAndHideStreak();
    }
  }

  // Hàm này được gọi khi widget nhận được thông tin mới (ví dụ: streakCount thay đổi)
  @override
  void didUpdateWidget(LessonProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Kích hoạt khi streak tăng lên (và đạt mốc 2)
    if (widget.streakCount >= 2 && widget.streakCount > oldWidget.streakCount) {
      _showAndHideStreak();
    }

    // Ẩn ngay lập tức nếu streak bị ngắt (quay về 0)
    if (widget.streakCount == 0 && oldWidget.streakCount > 0) {
      _streakTimer?.cancel();
      setState(() {
        _showStreakMessage = false;
      });
    }
  }

  // Hàm helper để hiển thị và tự động ẩn thông báo
  void _showAndHideStreak() {
    _streakTimer?.cancel(); // Hủy timer cũ nếu có

    setState(() {
      _showStreakMessage = true; // Hiện thông báo
    });

    // Bắt đầu timer mới để ẩn thông báo sau tokenized duration
    _streakTimer = Timer(AppProgressTokens.streakMessageDuration, () {
      setState(() {
        _showStreakMessage = false; // Ẩn thông báo
      });
    });
  }

  @override
  void dispose() {
    _streakTimer?.cancel(); // Rất quan trọng: Hủy timer khi widget bị xóa
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  final double barHeight = AppProgressTokens.defaultHeight;
  final double barRadius = AppProgressTokens.borderRadius;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // --- 1. THANH TIẾN ĐỘ ---
        // Dùng LayoutBuilder để lấy chiều rộng tối đa
        // và tính toán chiều rộng của thanh tiến độ (progress)
        SizedBox(
          height: barHeight,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double maxWidth = constraints.maxWidth;
              final double progressWidth = (maxWidth * widget.progress).clamp(0.0, maxWidth); // SỬA ĐỔI: Dùng widget.progress

              final double highlightWidth = maxWidth * AppProgressTokens.highlightWidthFraction;
              final double highlightHeight = barHeight * AppProgressTokens.highlightHeightFraction;
              final double highlightLeft = maxWidth * AppProgressTokens.highlightLeftFraction;

              return ClipRRect(
                borderRadius: BorderRadius.circular(barRadius),
                child: Stack(
                  // SỬA ĐỔI TẠI ĐÂY: Xóa 'fit: StackFit.expand'
                  children: [
                    // Lớp 1: Nền (Màu xám)
                    // SỬA ĐỔI TẠI ĐÂY: Bọc trong Positioned.fill
                    Positioned.fill(
                      child: Container(
                        color: AppColors.swan,
                      ),
                    ),

                    // Lớp 2: Tiến độ (Màu xanh lá)
                    // Giờ 'width' sẽ được tôn trọng
                    AnimatedContainer(
                      duration: AppProgressTokens.progressAnimation,
                      curve: Curves.easeInOut,
                      width: progressWidth,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                      ),
                    ),

                    // small white highlight overlay (relative positioning)
                    if (widget.progress > 0)
                      Positioned(
                        left: highlightLeft,
                        top: barHeight * 0.25,
                        child: Opacity(
                          opacity: 0.20,
                          child: Container(
                            width: highlightWidth,
                            height: highlightHeight,
                            decoration: ShapeDecoration(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(barRadius)),
                            ),
                          ),
                        ),
                      ),

                    // Lớp 3: Hiệu ứng bóng (Glossy/Shine)
                    Positioned.fill(
                      child: Container(
                        // SỬA ĐỔI TẠI ĐÂY:
                        // 1. Thêm bo góc cho lớp bóng
                        // 2. Điều chỉnh gradient 'stops'
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(barRadius),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withOpacity(0.3),
                              Colors.white.withOpacity(0.0),
                            ],
                            // Hiệu ứng bóng chỉ chiếm 50% trên cùng
                            stops: const [0.0, 0.5],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        // --- 2. THÔNG BÁO STREAK (CHUỖI) ---
        AnimatedSwitcher(
          duration: AppProgressTokens.progressAnimation,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.2),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          // SỬA ĐỔI: Dùng biến state '_showStreakMessage' thay vì 'widget.streakCount'
          child: (_showStreakMessage)
              ? Row(
                  key: ValueKey('streak_${widget.streakCount}'), // SỬA ĐỔI: Dùng widget.streakCount
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.whatshot,
                      color: AppColors.fox,
                      size: AppProgressTokens.streakIconSize,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.streakCount} câu liên tiếp!', // SỬA ĐỔI: Dùng widget.streakCount
                      style: TextStyle(
                        color: AppColors.fox,
                        fontWeight: FontWeight.bold,
                        fontSize: AppProgressTokens.streakFontSize,
                      ),
                    ),
                  ],
                )
              : const SizedBox(
                  key: ValueKey('no_streak'),
                  height: 20, // Giữ chiều cao để tránh nhảy layout
                ),
        ),
      ],
    );
  }
}


