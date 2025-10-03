import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/constants/app_colors.dart';

class GoalOptionTile extends StatelessWidget {
  final String time;
  final String title;
  final String subtitle;
  final String difficulty;
  final Color difficultyColor;
  final bool isSelected;
  final VoidCallback onTap;

  const GoalOptionTile({
    super.key,
    required this.time,
    required this.title,
    required this.subtitle,
    required this.difficulty,
    required this.difficultyColor,
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
            ? Border.all(color: AppColors.primaryGreen, width: 2.w)
            : null,
        ),
        child: Row(
          children: [
            _buildTimeDisplay(),
            SizedBox(width: 16.w),
            Expanded(child: _buildContent()),
            if (isSelected) _buildCheckIcon(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeDisplay() {
    return Container(
      width: 60.w,
      height: 60.h,
      decoration: BoxDecoration(
        color: isSelected 
          ? AppColors.primaryGreen.withOpacity(0.2)
          : Colors.grey[700],
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: Center(
        child: Text(
          time,
          style: TextStyle(
            color: isSelected ? AppColors.primaryGreen : Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
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
            color: isSelected ? AppColors.primaryGreen : Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: difficultyColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12.w),
          ),
          child: Text(
            difficulty,
            style: TextStyle(
              color: difficultyColor,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckIcon() {
    return Icon(
      Icons.check_circle,
      color: AppColors.primaryGreen,
      size: 24.sp,
    );
  }
}