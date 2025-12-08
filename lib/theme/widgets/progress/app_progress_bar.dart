import 'dart:async'; // Thêm thư viện 'async' để dùng Timer
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../colors.dart'; // Đảm bảo đường dẫn này chính xác
import 'app_progress_tokens.dart';

/// Hiển thị thanh tiến độ bài học và thông báo streak (chuỗi câu đúng).
class LessonProgressBar extends StatefulWidget { // SỬA ĐỔI: Chuyển sang StatefulWidget
  /// Giá trị tiến độ, từ 0.0 (0%) đến 1.0 (100%).
  final double progress;

  /// Số câu trả lời đúng liên tiếp hiện tại.
  final int streakCount;
  /// If true, the burst animation will only play when [confirmed] toggles
  /// from false -> true. This is useful when the app wants the progress
  /// animation + burst to happen on a 'confirm' action instead of on any
  /// progress change.
  final bool requireConfirmForBurst;

  /// Toggle that indicates a user 'confirm' action. When [requireConfirmForBurst]
  /// is true, the burst will play when this value changes from false -> true
  /// and progress has increased.
  final bool confirmed;
  /// If true, render streak message as an overlay positioned above the bar
  /// without increasing the widget's layout height. Useful when the bar is
  /// placed inside a single-line header.
  final bool overlayStreak;

  /// Vertical offset in logical pixels between the bar and the overlayed streak.
  final double overlayOffset;

  const LessonProgressBar({
    Key? key,
    required this.progress,
    this.streakCount = 0,
    this.overlayStreak = false,
    this.overlayOffset = 6.0,
    this.requireConfirmForBurst = false,
    this.confirmed = false,
  }) : super(key: key);

  @override
  State<LessonProgressBar> createState() => _LessonProgressBarState();
}

// THÊM MỚI: Tạo lớp State
class _LessonProgressBarState extends State<LessonProgressBar> with SingleTickerProviderStateMixin {
  Timer? _streakTimer;
  bool _showStreakMessage = false;
  late double _prevProgress;

  late final AnimationController _burstController;

  @override
  void initState() {
    super.initState();
    // Kiểm tra ngay khi widget được tạo lần đầu
    if (widget.streakCount >= 2) {
      _showAndHideStreak();
    }
    _prevProgress = widget.progress;
    _burstController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
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

    // Start burst animation when progress increases. If requireConfirmForBurst
    // is true, only play the burst when the confirmed flag toggles from
    // false->true. Otherwise play automatically after the fill animation.
    final bool progressIncreased = widget.progress > _prevProgress;
    final bool confirmNow = widget.requireConfirmForBurst
        ? (widget.confirmed && !oldWidget.confirmed)
        : true;

    if (progressIncreased && confirmNow) {
      Future.delayed(AppProgressTokens.progressAnimation, () {
        if (mounted) _burstController.forward(from: 0.0);
      });
    }
    _prevProgress = widget.progress;
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
    _burstController.dispose();
    super.dispose();
  }

  

  @override
  Widget build(BuildContext context) {
  final double barHeight = AppProgressTokens.defaultHeight;
  final double barRadius = AppProgressTokens.borderRadius;
  // Determine colors based on streak count:
  // - streak 3-4 -> bee
  // - streak >=5 -> fox
  // Otherwise use primary for fill and fox for streak text by default.
  late final Color fillColor;
  late final Color streakColor;
  if (widget.streakCount >= 5) {
    fillColor = AppColors.fox;
    streakColor = AppColors.fox;
  } else if (widget.streakCount >= 3) {
    fillColor = AppColors.bee;
    streakColor = AppColors.bee;
  } else {
    fillColor = AppColors.primary;
    streakColor = AppColors.primary;
  }

    // Build the streak widget (animated) so we can reuse it either below the bar
    // or overlay it above the bar depending on `overlayStreak`.
    final Widget streakAnimated = AnimatedSwitcher(
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
      child: (_showStreakMessage)
          ? Row(
              key: ValueKey('streak_${widget.streakCount}'),
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.whatshot,
                  color: streakColor,
                  size: AppProgressTokens.streakIconSize,
                ),
                const SizedBox(width: 4),
                Text(
                  '${widget.streakCount} câu liên tiếp!',
                  style: TextStyle(
                    color: streakColor,
                    fontWeight: FontWeight.bold,
                    fontSize: AppProgressTokens.streakFontSize,
                  ),
                ),
              ],
            )
          : const SizedBox(
              key: ValueKey('no_streak'),
              height: 0,
            ),
    );

    // If overlayStreak is true, render a fixed-height box for the bar and
    // position the streak above it (using negative offset) so the overall
    // layout height doesn't change — suitable for a single-line header.
    if (widget.overlayStreak) {
      // Increase container height to accommodate streak message overlay
      final double containerHeight = barHeight + AppProgressTokens.streakIconSize+4;
      
      return SizedBox(
        height: containerHeight,
        child: LayoutBuilder(builder: (context, constraints) {
          final double maxWidth = constraints.maxWidth;
          final double highlightWidth = maxWidth * AppProgressTokens.highlightWidthFraction;
          final double highlightHeight = barHeight * AppProgressTokens.highlightHeightFraction;
          final double highlightLeft = maxWidth * AppProgressTokens.highlightLeftFraction;

          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter, // Align bar to bottom, streak on top
            children: [
              // Background bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: barHeight,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(barRadius),
                  child: Container(color: AppColors.hare),
                ),
              ),

              // Filled portion (smoothly animates using TweenAnimationBuilder)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: barHeight,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: widget.progress.clamp(0.0, 1.0)),
                    duration: AppProgressTokens.progressAnimation,
                    curve: Curves.easeInOut,
                    builder: (context, value, child) {
                      final double v = value.clamp(0.0, 1.0);
                      return FractionallySizedBox(
                        widthFactor: v,
                        child: Container(
                          height: barHeight,
                          decoration: BoxDecoration(
                            color: fillColor,
                            borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(barRadius),
                              right: Radius.circular(v >= 1.0 ? barRadius : 0.0),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // highlight overlay
              if (widget.progress > 0)
                Positioned(
                  bottom: barHeight * 0.25,
                  left: highlightLeft,
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

              // Burst animation (bubbles) - appears when controller plays.
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: barHeight,
                child: LayoutBuilder(builder: (context, innerConstraints) {
                  final double maxW = innerConstraints.maxWidth;
                  final double originX = (widget.progress.clamp(0.0, 1.0)) * maxW;
                  final double clampedX = originX.clamp(6.0, maxW - 6.0);

                  return IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _burstController,
                      builder: (context, child) {
                        final t = _burstController.value;
                        // simple staggered bubbles
                        const int count = 6;
                        const double maxDistance = 28.0;
                        final List<Widget> bubbles = List.generate(count, (i) {
                          final double delay = i * 0.06;
                          final double localT = ((t - delay) / (1.0 - delay)).clamp(0.0, 1.0);
                          final double ease = Curves.easeOut.transform(localT);
                          final double angle = (i / count) * 2 * math.pi;
                          final double dx = math.cos(angle) * ease * maxDistance;
                          final double dy = math.sin(angle) * ease * maxDistance - ease * 6;
                          final double scale = 0.6 + 0.4 * ease;
                          final double opacity = (1.0 - ease).clamp(0.0, 1.0);

                          return Positioned(
                            left: clampedX + dx - 4,
                            top: (barHeight / 2) + dy - 4,
                            child: Opacity(
                              opacity: opacity,
                              child: Transform.scale(
                                scale: scale,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: fillColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          );
                        });

                        return Stack(children: bubbles);
                      },
                    ),
                  );
                }),
              ),

              // glossy overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: barHeight,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(barRadius),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white.withOpacity(0.3), Colors.white.withOpacity(0.0)],
                      stops: const [0.0, 0.5],
                    ),
                  ),
                ),
              ),

              // Streak overlay above the bar (now with proper spacing)
              if (_showStreakMessage)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Center(child: streakAnimated),
                ),
            ],
          );
        }),
      );
    }

    // Default behaviour: bar then streak below (keeps previous layout)
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: barHeight,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double maxWidth = constraints.maxWidth;
              final double highlightWidth = maxWidth * AppProgressTokens.highlightWidthFraction;
              final double highlightHeight = barHeight * AppProgressTokens.highlightHeightFraction;
              final double highlightLeft = maxWidth * AppProgressTokens.highlightLeftFraction;

              return ClipRRect(
                borderRadius: BorderRadius.circular(barRadius),
                child: Stack(
                  children: [
                    Positioned.fill(child: Container(color: AppColors.hare)),
                    // Filled portion (animate smoothly)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.0, end: widget.progress.clamp(0.0, 1.0)),
                        duration: AppProgressTokens.progressAnimation,
                        curve: Curves.easeInOut,
                        builder: (context, value, child) {
                          final double v = value.clamp(0.0, 1.0);
                          return FractionallySizedBox(
                            widthFactor: v,
                            child: Container(
                              height: barHeight,
                              decoration: BoxDecoration(
                                color: fillColor,
                                borderRadius: BorderRadius.horizontal(
                                  left: Radius.circular(barRadius),
                                  right: Radius.circular(v >= 1.0 ? barRadius : 0.0),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
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
                    // Burst animation (bubbles) - appears when controller plays.
                    // Compute origin by filled-edge so bubbles emanate from the new
                    // progress position.
                    Positioned.fill(
                      child: LayoutBuilder(builder: (context, innerConstraints) {
                        final double maxW = innerConstraints.maxWidth;
                        final double originX = (widget.progress.clamp(0.0, 1.0)) * maxW;
                        final double clampedX = originX.clamp(6.0, maxW - 6.0);

                        return IgnorePointer(
                          child: AnimatedBuilder(
                            animation: _burstController,
                            builder: (context, child) {
                              final t = _burstController.value;
                              // simple staggered bubbles
                              const int count = 6;
                              const double maxDistance = 28.0;
                              final List<Widget> bubbles = List.generate(count, (i) {
                                final double delay = i * 0.06;
                                final double localT = ((t - delay) / (1.0 - delay)).clamp(0.0, 1.0);
                                final double ease = Curves.easeOut.transform(localT);
                                final double angle = (i / count) * 2 * math.pi;
                                final double dx = math.cos(angle) * ease * maxDistance;
                                final double dy = math.sin(angle) * ease * maxDistance - ease * 6;
                                final double scale = 0.6 + 0.4 * ease;
                                final double opacity = (1.0 - ease).clamp(0.0, 1.0);

                                return Positioned(
                                  left: clampedX + dx - 4,
                                  top: (barHeight / 2) + dy - 4,
                                  child: Opacity(
                                    opacity: opacity,
                                    child: Transform.scale(
                                      scale: scale,
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: fillColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              });

                              return Stack(children: bubbles);
                            },
                          ),
                        );
                      }),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(barRadius),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.white.withOpacity(0.3), Colors.white.withOpacity(0.0)],
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
        // streak below
        Center(child: streakAnimated),
      ],
    );
  }
}


