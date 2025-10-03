import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BenefitItem extends StatelessWidget {
  final String icon;
  final String title;
  final String description;
  final Color iconColor;

  const BenefitItem({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildIcon(),
        SizedBox(width: 16.w),
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 48.w,
      height: 48.h,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: Center(
        child: Text(
          icon,
          style: TextStyle(fontSize: 24.sp),
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
            color: Colors.white,
            fontSize: 18.sp,
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
            height: 1.4,
          ),
        ),
      ],
    );
  }
}