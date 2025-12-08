import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/widgets/progress/app_progress_bar.dart';

class ExerciseHeader extends StatelessWidget {
  final int currentExercise;
  final int totalExercises;
  final String lessonTitle;
  final bool isRedoPhase;
  final VoidCallback? onBack;
  final Widget? trailing;
  final int streakCount;
  final double confirmedProgress;
  final bool answerConfirmed;

  const ExerciseHeader({
    super.key,
    required this.currentExercise,
    required this.totalExercises,
    required this.lessonTitle,
    required this.isRedoPhase,
    this.onBack,
    this.trailing,
    this.streakCount = 0,
    this.confirmedProgress = 0.0,
    this.answerConfirmed = false,
  });

  @override
  Widget build(BuildContext context) {
  // Use confirmedProgress (only increases on correct answer)
  final double progressValue = isRedoPhase ? 1.0 : confirmedProgress;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end, // Align to bottom
        children: [
          // Left: close or back - add bottom padding to align with progress bar
          IconButton(
            icon: Icon(
              onBack != null ? Icons.arrow_back : Icons.close,
              color: AppColors.macaw,
              size: 28.sp,
            ),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
            onPressed: onBack ?? () => Navigator.of(context).pop(),
          ),

          // Center: use the app's LessonProgressBar and let it fill width
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
              child: LessonProgressBar(
                progress: progressValue,
                streakCount: streakCount,
                overlayStreak: true,
                requireConfirmForBurst: true,
                confirmed: answerConfirmed,
              ),
            ),
          ),

          // Right: trailing (energy display) - add bottom padding to align with progress bar
          trailing ?? SizedBox(width: 48.w),
        ],
      ),
    );
  }
}
