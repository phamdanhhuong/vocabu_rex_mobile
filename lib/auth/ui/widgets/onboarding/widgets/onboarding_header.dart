import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/widgets/progress/app_progress_bar.dart';

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
          
          // Progress bar - sử dụng LessonProgressBar
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: LessonProgressBar(
                progress: progress,
                overlayStreak: true, // Overlay mode cho header
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
