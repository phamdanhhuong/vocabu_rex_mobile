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

  const ExerciseHeader({
    super.key,
    required this.currentExercise,
    required this.totalExercises,
    required this.lessonTitle,
    required this.isRedoPhase,
    this.onBack,
    this.trailing,
    this.streakCount = 0,
  });

  @override
  Widget build(BuildContext context) {
  // Show 0% on initial entry (currentExercise is 0-indexed).
  final double progressValue = isRedoPhase
    ? 1.0
    : (totalExercises > 0 ? (currentExercise) / totalExercises : 0.0);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: close or back
          IconButton(
            icon: Icon(
              onBack != null ? Icons.arrow_back : Icons.close,
              color: AppColors.macaw,
              size: 24.sp,
            ),
            onPressed: onBack ?? () => Navigator.of(context).pop(),
          ),

          // Center: use the app's LessonProgressBar and overlay index text
          // Center: use the app's LessonProgressBar and let it fill width
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              // Ensure the progress bar is vertically centered inside the Row
              child: Center(
                child: LessonProgressBar(
                  progress: progressValue,
                  streakCount: streakCount,
                  overlayStreak: true,
                ),
              ),
            ),
          ),

          // Right: trailing (energy display usually)
          trailing ?? SizedBox(width: 48.w),
        ],
      ),
    );
  }
}
