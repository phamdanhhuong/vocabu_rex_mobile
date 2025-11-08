import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

class WelcomeHeader extends StatelessWidget {
  const WelcomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 30.h, bottom: 20.h),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 45.w,
              height: 45.h,
              decoration: BoxDecoration(
                color: AppColors.featherGreen,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.school,
                color: AppColors.snow,
                size: 28.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              'Vocaburex',
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.featherGreen,
                letterSpacing: -1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
