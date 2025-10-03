import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/constants/app_colors.dart';

class LevelOptionTile extends StatelessWidget {
  final String title;
  final String description;
  final double progress;
  final bool isSelected;
  final VoidCallback onTap;

  const LevelOptionTile({
    super.key,
    required this.title,
    required this.description,
    required this.progress,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _buildContent()),
                if (isSelected) _buildCheckIcon(),
              ],
            ),
            SizedBox(height: 16.h),
            _buildProgressBar(),
          ],
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
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 8.h),
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

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trình độ hiện tại',
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          height: 8.h,
          decoration: BoxDecoration(
            color: Colors.grey[700],
            borderRadius: BorderRadius.circular(4.h),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryGreen : Colors.orange,
                borderRadius: BorderRadius.circular(4.h),
              ),
            ),
          ),
        ),
      ],
    );
  }
}