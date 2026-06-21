import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/core/app_preferences.dart';

/// Type mode for ListenChoose - inset neumorphic text field
class ListenChooseTypeMode extends StatelessWidget {
  final TextEditingController controller;
  final bool isSubmitted;
  final bool revealed;
  final bool? isCorrect;
  final String correctAnswer;

  const ListenChooseTypeMode({
    super.key,
    required this.controller,
    required this.isSubmitted,
    required this.revealed,
    required this.isCorrect,
    required this.correctAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppPreferences().isDarkMode;
    
    Color borderColor = Colors.transparent;
    if (isCorrect != null) {
      borderColor = isCorrect! ? AppColors.featherGreen : AppColors.cardinal;
    } else {
      borderColor = AppColors.hare.withValues(alpha: 0.5);
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          // Neumorphic Inset Text Field
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.swan : AppColors.snow,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: borderColor,
                width: isCorrect == null ? 1 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black.withValues(alpha: 0.8) : AppColors.hare.withValues(alpha: 0.5),
                  offset: const Offset(0, 4),
                  blurRadius: 4,
                   // Inner shadow effect for inset look
                )
              ],
            ),
            child: TextField(
              controller: controller,
              enabled: !isSubmitted && !revealed,
              decoration: InputDecoration(
                hintText: 'Nhập câu trả lời...',
                hintStyle: TextStyle(
                  color: AppColors.hare,
                  fontSize: 16.sp,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              ),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.snow : AppColors.eel,
              ),
              maxLines: 3,
            ),
          ),

          if (isCorrect != null && !isCorrect!) ...[
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.correctGreenLight,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.primary, width: 1),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primary,
                    size: 24.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Đáp án: $correctAnswer',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
