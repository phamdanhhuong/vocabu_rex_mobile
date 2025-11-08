import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

class AssessmentOptionTile extends StatelessWidget {
  final String icon;
  final String title;
  final String description;
  final String? buttonText;
  final String value;
  final bool hasBlueAccent;
  final bool isSelected;
  final VoidCallback onTap;

  const AssessmentOptionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.buttonText,
    required this.value,
    this.hasBlueAccent = false,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(16.w),
          border: isSelected
            ? Border.all(color: AppColors.macaw, width: 2.w)
            : (hasBlueAccent 
                ? Border.all(color: AppColors.macaw.withOpacity(0.5), width: 1.w)
                : null),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIcon(),
            SizedBox(width: 16.w),
            Expanded(child: _buildContent()),
            _buildTrailingElement(),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 40.w,
      height: 40.h,
      decoration: BoxDecoration(
        color: isSelected
          ? AppColors.macaw.withOpacity(0.3)
          : (hasBlueAccent 
              ? AppColors.macaw.withOpacity(0.2)
              : Colors.orange.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(10.w),
      ),
      child: Center(
        child: Text(
          icon,
          style: TextStyle(fontSize: 20.sp),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: isSelected
              ? AppColors.macaw 
              : (hasBlueAccent ? AppColors.macaw : Colors.white),
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          description,
          style: TextStyle(
            color: Colors.grey[300],
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildTrailingElement() {
    // Selection indicator has priority
    if (isSelected) {
      return Icon(
        Icons.check_circle,
        color: AppColors.macaw,
        size: 24.sp,
      );
    }
    
    // Button (only for first option and not selected)
    if (buttonText != null) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: 12.w,
          vertical: 8.h,
        ),
        decoration: BoxDecoration(
          color: AppColors.macaw.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20.w),
        ),
        child: Text(
          buttonText!,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}