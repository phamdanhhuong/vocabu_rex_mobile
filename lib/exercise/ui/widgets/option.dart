import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/constants/app_colors.dart';

class Option extends StatelessWidget {
  final String label;
  final bool isSelected;

  const Option({super.key, required this.isSelected, required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        height: 50.h,
        margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: AppColors.transparent,
          borderRadius: BorderRadius.all(Radius.circular(18.r)),
          border: isSelected
              ? Border.all(color: AppColors.primaryBlue, width: 3)
              : Border.all(color: AppColors.borderGrey),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(color: AppColors.characterBlue, fontSize: 16.sp),
          ),
        ),
      ),
    );
  }
}
