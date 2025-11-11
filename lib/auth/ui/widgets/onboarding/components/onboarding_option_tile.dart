import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/typography.dart';

/// Reusable onboarding option tile with Duolingo-style animations
/// Used for language selection, level selection, and other onboarding choices
class OnboardingOptionTile extends StatefulWidget {
  final Widget? leading; // Icon, flag emoji, or custom widget
  final String title;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? selectedColor;
  final bool showCheckmark;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const OnboardingOptionTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    required this.isSelected,
    required this.onTap,
    this.selectedColor,
    this.showCheckmark = true,
    this.padding,
    this.margin,
  });

  @override
  State<OnboardingOptionTile> createState() => _OnboardingOptionTileState();
}

class _OnboardingOptionTileState extends State<OnboardingOptionTile>
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

  Color get _selectedColor => widget.selectedColor ?? AppColors.primary;

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
              margin: widget.margin ?? EdgeInsets.symmetric(horizontal: 24.w, vertical: 6.h),
              padding: widget.padding ?? EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.snow,
                border: Border.all(
                  color: widget.isSelected ? _selectedColor : AppColors.swan,
                  width: widget.isSelected ? 2.w : 1.w,
                ),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: widget.isSelected 
                        ? _selectedColor.withOpacity(0.2)
                        : Colors.black.withOpacity(0.05),
                    offset: Offset(0, _pressed ? 2 : 4),
                    blurRadius: _pressed ? 4 : 8,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (widget.leading != null) ...[
                    widget.leading!,
                    SizedBox(width: 16.w),
                  ],
                  Expanded(child: _buildContent()),
                  if (widget.showCheckmark && widget.isSelected) _buildCheckmark(),
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.title,
          style: AppTypography.defaultTextTheme().titleMedium?.copyWith(
                color: widget.isSelected ? _selectedColor : AppColors.eel,
                fontWeight: FontWeight.w700,
              ),
        ),
        if (widget.subtitle != null) ...[
          SizedBox(height: 4.h),
          Text(
            widget.subtitle!,
            style: AppTypography.defaultTextTheme().bodyMedium?.copyWith(
                  color: AppColors.wolf,
                ),
          ),
        ],
      ],
    );
  }

  Widget _buildCheckmark() {
    return Icon(
      Icons.check_circle,
      color: _selectedColor,
      size: 24.sp,
    );
  }
}

/// Language tile variant with flag emoji
class LanguageTile extends StatelessWidget {
  final String flagEmoji;
  final String languageName;
  final bool isSelected;
  final VoidCallback onTap;

  const LanguageTile({
    super.key,
    required this.flagEmoji,
    required this.languageName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingOptionTile(
      leading: Container(
        width: 48.w,
        height: 36.h,
        decoration: BoxDecoration(
          color: AppColors.polar,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.swan, width: 1.w),
        ),
        child: Center(
          child: Text(
            flagEmoji,
            style: TextStyle(fontSize: 24.sp),
          ),
        ),
      ),
      title: languageName,
      isSelected: isSelected,
      onTap: onTap,
      selectedColor: AppColors.macaw,
    );
  }
}

/// Level tile variant with signal bars
class LevelTile extends StatelessWidget {
  final String title;
  final String? description;
  final int level; // 1-5
  final bool isSelected;
  final VoidCallback onTap;

  const LevelTile({
    super.key,
    required this.title,
    this.description,
    required this.level,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingOptionTile(
      leading: _buildLevelBars(),
      title: title,
      subtitle: description,
      isSelected: isSelected,
      onTap: onTap,
      selectedColor: AppColors.macaw,
    );
  }

  Widget _buildLevelBars() {
    return SizedBox(
      width: 24.w,
      height: 36.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(5, (index) {
          final isActive = index < level;
          final barHeight = 8.h + (index * 6.h);
          return Container(
            width: 3.w,
            height: barHeight,
            decoration: BoxDecoration(
              color: isActive 
                  ? (isSelected ? AppColors.macaw : AppColors.primary)
                  : AppColors.hare,
              borderRadius: BorderRadius.circular(2.r),
            ),
          );
        }),
      ),
    );
  }
}

/// Goal tile variant with icon and description
class GoalSelectionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const GoalSelectionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingOptionTile(
      leading: Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primary.withOpacity(0.15)
              : AppColors.polar,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(
          icon,
          color: isSelected ? AppColors.primary : AppColors.wolf,
          size: 24.sp,
        ),
      ),
      title: title,
      subtitle: description,
      isSelected: isSelected,
      onTap: onTap,
      selectedColor: AppColors.primary,
    );
  }
}
