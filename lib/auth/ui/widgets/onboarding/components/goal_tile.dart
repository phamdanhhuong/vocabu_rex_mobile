import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/constants/app_colors.dart';

class GoalTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const GoalTile({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
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
            _buildIcon(),
            SizedBox(width: 16.w),
            Expanded(child: _buildContent()),
            if (isSelected) _buildCheckIcon(),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryGreen.withOpacity(0.2) : Colors.grey[700],
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: Icon(
        icon,
        color: isSelected ? AppColors.primaryGreen : Colors.grey[400],
        size: 24.sp,
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
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          description,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            height: 1.3,
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