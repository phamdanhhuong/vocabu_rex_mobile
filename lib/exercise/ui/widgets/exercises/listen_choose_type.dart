import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

/// Type mode for ListenChoose - text input field
class ListenChooseTypeMode extends StatelessWidget {
  final TextEditingController controller;
  final bool isSubmitted;
  final bool revealed;
  final bool? isCorrect;
  final String correctAnswer;

  const ListenChooseTypeMode({
    Key? key,
    required this.controller,
    required this.isSubmitted,
    required this.revealed,
    required this.isCorrect,
    required this.correctAnswer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color? borderColor;
    if (isCorrect != null) {
      borderColor = isCorrect! ? AppColors.primary : AppColors.cardinal;
    }
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          TextField(
            controller: controller,
            enabled: !isSubmitted && !revealed,
            decoration: InputDecoration(
              hintText: 'Nhập câu trả lời...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: borderColor ?? Colors.grey[400]!, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: borderColor ?? Colors.grey[400]!, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: borderColor ?? AppColors.eel, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            style: TextStyle(fontSize: 16.sp),
            maxLines: 3,
          ),
          
          if (isCorrect != null && !isCorrect!) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.correctGreenLight,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.primary, size: 20.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Đáp án: $correctAnswer',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
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
