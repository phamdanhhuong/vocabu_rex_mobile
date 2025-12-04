import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

/// Header with progress bar and back button for onboarding
/// Similar to ExerciseHeader
class OnboardingHeader extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onBack;
  
  const OnboardingHeader({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
    this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = totalSteps > 0 ? currentStep / totalSteps : 0.0;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Back or Close button
          IconButton(
            icon: Icon(
              currentStep > 0 ? Icons.arrow_back : Icons.close,
              color: AppColors.wolf,
              size: 24.sp,
            ),
            onPressed: onBack ?? () => Navigator.of(context).pop(),
          ),
          
          // Progress bar
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Center(
                child: Container(
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(16.w),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.featherGreen,
                        borderRadius: BorderRadius.circular(16.w),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Spacer for symmetry
          SizedBox(width: 48.w),
        ],
      ),
    );
  }
}
