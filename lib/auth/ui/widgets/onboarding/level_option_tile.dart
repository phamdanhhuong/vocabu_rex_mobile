import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/constants/app_colors.dart';

class LevelOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const LevelOptionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : Colors.grey[700]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            // Level indicator bars
            _buildLevelBars(),
            
            SizedBox(width: 16.w),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? AppColors.primaryBlue : AppColors.textWhite,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    description,
                    style: TextStyle(
                      color: AppColors.textGray,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
            
            // Selection indicator
            if (isSelected)
              Container(
                width: 20.w,
                height: 20.h,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: AppColors.textWhite,
                  size: 14.sp,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelBars() {
    return Column(
      children: [
        _buildBar(true),
        SizedBox(height: 2.h),
        _buildBar(title != 'Tôi mới học tiếng Anh'),
        SizedBox(height: 2.h),
        _buildBar(title == 'Tôi có thể đi sâu vào hầu hết các chủ đề'),
        SizedBox(height: 2.h),
        _buildBar(title == 'Tôi có thể đi sâu vào hầu hết các chủ đề'),
      ],
    );
  }

  Widget _buildBar(bool isActive) {
    return Container(
      width: 4.w,
      height: 8.h,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryBlue : Colors.grey[600],
        borderRadius: BorderRadius.circular(2.r),
      ),
    );
  }
}