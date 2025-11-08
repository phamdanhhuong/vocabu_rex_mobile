import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

class LanguageOptionTile extends StatelessWidget {
  final String flagEmoji;
  final String languageName;
  final bool isSelected;
  final VoidCallback onTap;

  const LanguageOptionTile({
    super.key,
    required this.flagEmoji,
    required this.languageName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 6.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          border: Border.all(
            color: isSelected ? AppColors.macaw : Colors.grey[700]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            // Flag container
            Container(
              width: 40.w,
              height: 30.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.r),
                border: Border.all(color: Colors.grey[600]!),
              ),
              child: Center(
                child: Text(
                  flagEmoji,
                  style: TextStyle(fontSize: 20.sp),
                ),
              ),
            ),
            
            SizedBox(width: 16.w),
            
            // Language name
            Expanded(
              child: Text(
                languageName,
                style: TextStyle(
                  color: isSelected ? AppColors.macaw : AppColors.snow,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            // Selection indicator
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.macaw,
                size: 20.sp,
              ),
          ],
        ),
      ),
    );
  }
}