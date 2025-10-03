import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/constants/app_colors.dart';

class NotificationPermissionScreen extends StatelessWidget {
  final Function(bool) onPermissionSelected;

  const NotificationPermissionScreen({
    super.key,
    required this.onPermissionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
              children: [
                SizedBox(height: 80.h),
          
          Text(
            'Tôi sẽ nhắc bạn luyện tập để\ngiúp bạn tạo thói quen học\ntập nhé!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: 100.h),
          
          // Notification permission dialog
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(20.w),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.notifications,
                  size: 48.sp,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16.h),
                Text(
                  'Cho phép Duolingo gửi thông báo?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),
                
                // Allow button
                GestureDetector(
                  onTap: () => onPermissionSelected(true),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(12.w),
                    ),
                    child: Text(
                      'Cho phép',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                
                SizedBox(height: 12.h),
                
                // Don't allow button
                GestureDetector(
                  onTap: () => onPermissionSelected(false),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(12.w),
                    ),
                    child: Text(
                      'Không cho phép',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 32.h), // Extra space instead of Spacer
        ],
      ),
    ));
  }
}