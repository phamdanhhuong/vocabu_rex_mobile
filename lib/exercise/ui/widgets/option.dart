import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

class Option extends StatelessWidget {
  final String label;
  final bool isSelected;
  final int index;
  final Function(int) onSelect;

  const Option({
    super.key,
    required this.isSelected,
    required this.label,
    required this.index,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onSelect(index),
      child: Container(
        height: 50.h,
        margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.all(Radius.circular(18.r)),
          border: isSelected
              ? Border.all(color: AppColors.macaw, width: 3)
              : Border.all(color: AppColors.swan),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(color: AppColors.macaw, fontSize: 16.sp),
          ),
        ),
      ),
    );
  }
}
