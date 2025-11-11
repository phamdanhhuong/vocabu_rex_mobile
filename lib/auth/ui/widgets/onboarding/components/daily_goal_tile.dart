import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/typography.dart';

/// Daily goal option tile with Duolingo-style design
class DailyGoalTile extends StatefulWidget {
  final String time;
  final String title;
  final String subtitle;
  final String difficulty;
  final Color difficultyColor;
  final bool isSelected;
  final VoidCallback onTap;

  const DailyGoalTile({
    super.key,
    required this.time,
    required this.title,
    required this.subtitle,
    required this.difficulty,
    required this.difficultyColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<DailyGoalTile> createState() => _DailyGoalTileState();
}

class _DailyGoalTileState extends State<DailyGoalTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _pressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _pressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    setState(() => _pressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              decoration: BoxDecoration(
                color: AppColors.snow,
                border: Border.all(
                  color: widget.isSelected ? AppColors.primary : AppColors.swan,
                  width: widget.isSelected ? 2.w : 1.w,
                ),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: widget.isSelected
                        ? AppColors.primary.withOpacity(0.2)
                        : Colors.black.withOpacity(0.05),
                    offset: Offset(0, _pressed ? 2 : 4),
                    blurRadius: _pressed ? 4 : 8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(child: _buildContent()),
                  SizedBox(width: 16.w),
                  _buildTimeDisplay(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: AppTypography.defaultTextTheme().titleMedium?.copyWith(
                color: widget.isSelected ? AppColors.primary : AppColors.eel,
                fontWeight: FontWeight.w700,
              ),
        ),
        SizedBox(height: 4.h),
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: widget.difficultyColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                widget.difficulty,
                style: AppTypography.defaultTextTheme().labelSmall?.copyWith(
                      color: widget.difficultyColor,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              widget.subtitle,
              style: AppTypography.defaultTextTheme().bodySmall?.copyWith(
                    color: AppColors.wolf,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeDisplay() {
    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        color: widget.isSelected
            ? AppColors.primary.withOpacity(0.15)
            : AppColors.polar,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: widget.isSelected ? AppColors.primary : AppColors.swan,
          width: 1.w,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.time,
            style: AppTypography.defaultTextTheme().headlineSmall?.copyWith(
                  color: widget.isSelected ? AppColors.primary : AppColors.eel,
                  fontWeight: FontWeight.w800,
                ),
          ),
          Text(
            'phút',
            style: AppTypography.defaultTextTheme().labelSmall?.copyWith(
                  color: AppColors.wolf,
                  fontSize: 10.sp,
                ),
          ),
        ],
      ),
    );
  }
}
