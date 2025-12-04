import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import '../models/onboarding_models.dart';

/// Generic option tile that adapts to different layouts
class OnboardingOptionTile extends StatefulWidget {
  final String title;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final OptionTileLayout layout;
  
  // Layout-specific props
  final IconData? icon;
  final String? emoji;
  final String? timeBadge;
  final Color? badgeColor;
  final String? badgeText;
  final double? progressValue;
  
  const OnboardingOptionTile({
    Key? key,
    required this.title,
    this.subtitle,
    required this.isSelected,
    required this.onTap,
    this.layout = OptionTileLayout.icon,
    this.icon,
    this.emoji,
    this.timeBadge,
    this.badgeColor,
    this.badgeText,
    this.progressValue,
  }) : super(key: key);

  @override
  State<OnboardingOptionTile> createState() => _OnboardingOptionTileState();
}

class _OnboardingOptionTileState extends State<OnboardingOptionTile> {
  bool _pressed = false;
  static const Duration _pressDuration = Duration(milliseconds: 90);

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) {
        _setPressed(false);
        widget.onTap();
      },
      onTapCancel: () => _setPressed(false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: _pressDuration,
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _pressed ? 2.0 : 0, 0),
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          // Nền sáng để dễ đọc (như WordTile)
          color: widget.isSelected ? AppColors.selectionBlueLight : AppColors.snow,
          borderRadius: BorderRadius.circular(16.w),
          border: Border.all(
            color: widget.isSelected 
                ? AppColors.macaw // Viền xanh khi chọn
                : AppColors.swan,  // Viền xám mặc định
            width: 2.0,
          ),
          boxShadow: [
            // Shadow phía dưới (3D effect như WordTile)
            BoxShadow(
              color: widget.isSelected 
                  ? AppColors.selectionBlueDark 
                  : AppColors.hare,
              offset: Offset(0, _pressed ? 2 : 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            _buildLeading(),
            if (widget.layout != OptionTileLayout.simple) SizedBox(width: 16.w),
            Expanded(child: _buildContent()),
            if (widget.isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.macaw,
                size: 24.sp,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeading() {
    switch (widget.layout) {
      case OptionTileLayout.emoji:
        return Text(
          widget.emoji ?? '🎯',
          style: TextStyle(fontSize: 32.sp),
        );
      
      case OptionTileLayout.timeBadge:
        return Container(
          width: 60.w,
          height: 60.h,
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.macaw.withValues(alpha: 0.15)
                : AppColors.polar,
            borderRadius: BorderRadius.circular(12.w),
            border: Border.all(
              color: widget.isSelected ? AppColors.macaw : AppColors.swan,
              width: 2.0,
            ),
          ),
          child: Center(
            child: Text(
              widget.timeBadge ?? '0',
              style: TextStyle(
                color: widget.isSelected 
                    ? AppColors.macaw 
                    : AppColors.eel,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      
      case OptionTileLayout.icon:
        return Container(
          width: 48.w,
          height: 48.w,
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.macaw.withValues(alpha: 0.15)
                : AppColors.polar,
            borderRadius: BorderRadius.circular(12.w),
            border: Border.all(
              color: widget.isSelected ? AppColors.macaw : AppColors.swan,
              width: 2.0,
            ),
          ),
          child: Icon(
            widget.icon ?? Icons.check,
            color: widget.isSelected 
                ? AppColors.macaw 
                : AppColors.eel,
            size: 24.sp,
          ),
        );
      
      case OptionTileLayout.simple:
        return const SizedBox.shrink();
    }
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: TextStyle(
            // Text tối để dễ đọc trên nền sáng
            color: widget.isSelected 
                ? AppColors.macaw 
                : AppColors.eel,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (widget.subtitle != null) ...[
          SizedBox(height: 4.h),
          Text(
            widget.subtitle!,
            style: TextStyle(
              color: AppColors.wolf, // Xám tối để dễ đọc
              fontSize: 14.sp,
              height: 1.3,
            ),
          ),
        ],
        if (widget.progressValue != null) ...[
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.w),
            child: LinearProgressIndicator(
              value: widget.progressValue,
              backgroundColor: AppColors.swan,
              valueColor: AlwaysStoppedAnimation<Color>(
                widget.isSelected 
                    ? AppColors.macaw 
                    : AppColors.featherGreen,
              ),
              minHeight: 6.h,
            ),
          ),
        ],
        if (widget.badgeText != null) ...[
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: (widget.badgeColor ?? AppColors.macaw).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12.w),
            ),
            child: Text(
              widget.badgeText!,
              style: TextStyle(
                color: widget.badgeColor ?? AppColors.macaw,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
