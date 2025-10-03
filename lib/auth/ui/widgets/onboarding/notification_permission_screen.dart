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
    return Column(
      children: [
        // Fixed header section
        _buildFixedHeader(),
        
        // Scrollable content
        Expanded(
          child: _buildScrollableContent(),
        ),
      ],
    );
  }

  Widget _buildFixedHeader() {
    return Column(
      children: [
        SizedBox(height: 40.h),
        _buildDuoCharacter(),
        SizedBox(height: 40.h),
      ],
    );
  }

  Widget _buildScrollableContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          children: [
            _buildMessage(),
            SizedBox(height: 60.h),
            _buildNotificationIcon(),
            SizedBox(height: 40.h),
            _buildButtons(),
            SizedBox(height: 32.h), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildDuoCharacter() {
    return Container(
      width: 120.w,
      height: 120.h,
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(60.w),
        border: Border.all(color: Colors.grey[800]!, width: 4),
      ),
      child: Stack(
        children: [
          Container(
            width: 120.w,
            height: 120.h,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.circular(60.w),
            ),
          ),
          _buildEye(left: 25.w),
          _buildEye(right: 25.w),
          _buildBeak(),
          _buildBell(), // Bell for notification
        ],
      ),
    );
  }

  Widget _buildEye({double? left, double? right}) {
    return Positioned(
      left: left,
      right: right,
      top: 35.h,
      child: Container(
        width: 18.w,
        height: 25.h,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: Center(
          child: Container(
            width: 8.w,
            height: 12.h,
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.all(Radius.circular(6)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBeak() {
    return Positioned(
      left: 52.w,
      top: 65.h,
      child: Container(
        width: 16.w,
        height: 12.h,
        decoration: const BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildBell() {
    return Positioned(
      right: 10.w,
      top: 15.h,
      child: Container(
        width: 20.w,
        height: 20.h,
        decoration: BoxDecoration(
          color: Colors.yellow,
          borderRadius: BorderRadius.circular(10.w),
        ),
        child: Icon(
          Icons.notifications,
          size: 12.sp,
          color: Colors.orange,
        ),
      ),
    );
  }

  Widget _buildMessage() {
    return Text(
      'Tôi sẽ nhắc bạn luyện tập để\ngiúp bạn tạo thói quen học\ntập nhé!',
      style: TextStyle(
        color: Colors.white,
        fontSize: 24.sp,
        fontWeight: FontWeight.w700,
        height: 1.3,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildNotificationIcon() {
    return Container(
      width: 100.w,
      height: 100.h,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(50.w),
      ),
      child: Icon(
        Icons.notifications_active,
        size: 50.sp,
        color: AppColors.primaryGreen,
      ),
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        _buildActionButton(
          title: 'HÃY NHẮC TÔI HỌC NHÉ',
          onTap: () => onPermissionSelected(true),
          isPrimary: true,
        ),
        SizedBox(height: 16.h),
        _buildActionButton(
          title: 'KHÔNG CẦN',
          onTap: () => onPermissionSelected(false),
          isPrimary: false,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String title,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 18.h),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(16.w),
          border: isPrimary ? null : Border.all(color: Colors.grey[600]!, width: 1.w),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isPrimary ? Colors.white : Colors.grey[400],
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}