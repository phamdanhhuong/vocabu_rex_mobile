import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

class OnboardingHeader extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onBack;

  const OnboardingHeader({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          if (onBack != null)
            IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: AppColors.wolf,
                size: 24.sp,
              ),
              onPressed: onBack,
            )
          else
            SizedBox(width: 48.w),
          
          Expanded(
            child: Container(
              height: 8.h,
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.r),
                color: Colors.grey[800],
              ),
              child: LinearProgressIndicator(
                value: currentStep / totalSteps,
                backgroundColor: Colors.grey[800],
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.featherGreen),
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
          
          SizedBox(width: 48.w),
        ],
      ),
    );
  }
}