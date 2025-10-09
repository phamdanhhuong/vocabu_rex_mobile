import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/constants/app_colors.dart';

class ExerciseHeader extends StatelessWidget {
  final int currentExercise;
  final int totalExercises;
  final String lessonTitle;
  final bool isRedoPhase;
  final VoidCallback? onBack;

  const ExerciseHeader({
    super.key,
    required this.currentExercise,
    required this.totalExercises,
    required this.lessonTitle,
    required this.isRedoPhase,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        children: [
          // Top row with back button and close button
          Row(
            children: [
              if (onBack != null)
                IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: AppColors.textBlue,
                    size: 24.sp,
                  ),
                  onPressed: onBack,
                )
              else
                SizedBox(width: 48.w),

              Expanded(
                child: Text(
                  lessonTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textBlue,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              IconButton(
                icon: Icon(Icons.close, color: AppColors.textBlue, size: 24.sp),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // Progress bar row
          Row(
            children: [
              Text(
                '${currentExercise + 1}',
                style: TextStyle(
                  color: AppColors.textBlue,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),

              Expanded(
                child: Container(
                  height: 8.h,
                  margin: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.r),
                    color: Colors.grey[300],
                  ),
                  child: LinearProgressIndicator(
                    value: isRedoPhase
                        ? 1.0
                        : totalExercises > 0
                        ? (currentExercise + 1) / totalExercises
                        : 0,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isRedoPhase
                          ? AppColors.primaryYellow
                          : AppColors.primaryGreen,
                    ),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),

              Text(
                '$totalExercises',
                style: TextStyle(
                  color: AppColors.textBlue,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
