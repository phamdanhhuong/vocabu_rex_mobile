import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/core/biometric_service.dart';
import 'package:vocabu_rex_mobile/core/token_manager.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

class BiometricEnableDialog {
  static Future<void> show(BuildContext context) async {
    // Kiểm tra thiết bị có hỗ trợ sinh trắc học không
    final isAvailable = await BiometricService.isBiometricAvailable();
    if (!isAvailable) return;

    // Kiểm tra đã bật chưa
    final isEnabled = await TokenManager.isBiometricsEnabled();
    if (isEnabled) return; // Đã bật rồi thì không hỏi nữa

    // Lấy tên loại sinh trắc học
    final biometricType = await BiometricService.getBiometricTypeName();

    if (!context.mounted) return;

    final theme = Theme.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.eel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Row(
          children: [
            Icon(
              biometricType.contains('Face') ? Icons.face : Icons.fingerprint,
              color: AppColors.macaw,
              size: 32.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'Đăng nhập nhanh',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: AppColors.snow,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Bạn có muốn sử dụng $biometricType để đăng nhập nhanh hơn cho lần sau không?',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.hare,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              // Người dùng không muốn dùng
              await TokenManager.setBiometricsEnabled(false);
              if (context.mounted) Navigator.of(context).pop();
            },
            child: Text(
              'Không, cảm ơn',
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppColors.wolf,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              // Bật tính năng sinh trắc học
              await TokenManager.setBiometricsEnabled(true);
              if (context.mounted) Navigator.of(context).pop();
              
              // Hiển thị thông báo thành công
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã bật đăng nhập bằng $biometricType'),
                    backgroundColor: AppColors.featherGreen,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.macaw,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
            child: Text(
              'Bật ngay',
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppColors.snow,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
