import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/constants/app_colors.dart';

class SkipButton extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final String text;

  const SkipButton({
    super.key,
    this.isSelected = false,
    required this.onTap,
    this.text = 'Tạm thời bỏ qua',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16.w),
            border: Border.all(
              color: isSelected ? AppColors.primaryBlue : Colors.grey[600]!, 
              width: isSelected ? 2.w : 1.w,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style: TextStyle(
                  color: isSelected ? AppColors.primaryBlue : Colors.grey[400],
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (isSelected) ...[
                SizedBox(width: 8.w),
                Icon(
                  Icons.check_circle,
                  color: AppColors.primaryBlue,
                  size: 20.sp,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}