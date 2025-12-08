import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/app_button.dart';

class InsufficientEnergyDialog extends StatelessWidget {
  final int currentEnergy;
  final int requiredEnergy;
  final VoidCallback? onBuyEnergy;

  const InsufficientEnergyDialog({
    super.key,
    required this.currentEnergy,
    this.requiredEnergy = 1,
    this.onBuyEnergy,
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
            // Energy Icon
            Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                color: AppColors.cardinal.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.battery_0_bar_rounded,
                size: 48.sp,
                color: AppColors.cardinal,
              ),
            ),
            SizedBox(height: 20.h),
            
            // Title
            Text(
              'Không đủ năng lượng',
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
              'Bạn cần ít nhất $requiredEnergy trái tim để bắt đầu bài học.\n\nNăng lượng hiện tại: $currentEnergy ❤️',
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.humpback,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            
            // Buttons
            Column(
              children: [
                if (onBuyEnergy != null)
                  AppButton(
                    label: 'MUA NĂNG LƯỢNG',
                    onPressed: () {
                      Navigator.of(context).pop();
                      onBuyEnergy?.call();
                    },
                    variant: ButtonVariant.primary,
                    size: ButtonSize.medium,
                  ),
                if (onBuyEnergy != null) SizedBox(height: 12.h),
                AppButton(
                  label: 'ĐÓNG',
                  onPressed: () => Navigator.of(context).pop(),
                  variant: ButtonVariant.secondary,
                  size: ButtonSize.medium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> show(
    BuildContext context, {
    required int currentEnergy,
    int requiredEnergy = 1,
    VoidCallback? onBuyEnergy,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => InsufficientEnergyDialog(
        currentEnergy: currentEnergy,
        requiredEnergy: requiredEnergy,
        onBuyEnergy: onBuyEnergy,
      ),
    );
  }
}
