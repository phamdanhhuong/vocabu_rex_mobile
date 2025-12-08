import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/app_button.dart';

class RedoPhaseDialog extends StatelessWidget {
  final VoidCallback onContinue;

  const RedoPhaseDialog({
    super.key,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Container(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                color: AppColors.featherGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.refresh_rounded,
                size: 48.sp,
                color: AppColors.featherGreen,
              ),
            ),
            SizedBox(height: 20.h),
            
            // Title
            Text(
              'Làm lại câu sai',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.eel,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            
            // Message
            Text(
              'Bạn đã hoàn thành tất cả các câu hỏi!\n\nBây giờ hãy làm lại những câu sai để hoàn thiện bài học.',
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.humpback,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            
            // Energy info
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.correctGreenLight.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20.sp,
                    color: AppColors.featherGreen,
                  ),
                  SizedBox(width: 8.w),
                  Flexible(
                    child: Text(
                      'Không bị trừ năng lượng khi làm lại',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.featherGreen,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            
            // Continue Button
            AppButton(
              label: 'TIẾP TỤC',
              onPressed: () {
                Navigator.of(context).pop();
                onContinue();
              },
              variant: ButtonVariant.primary,
              size: ButtonSize.medium,
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> show(BuildContext context, VoidCallback onContinue) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RedoPhaseDialog(onContinue: onContinue),
    );
  }
}
