import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/constants/app_colors.dart';

class LearningBenefitsScreen extends StatelessWidget {
  const LearningBenefitsScreen({super.key});

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
        SizedBox(height: 20.h),
        _buildDuoCharacter(),
        SizedBox(height: 40.h),
        _buildSpeechBubble(),
        SizedBox(height: 40.h),
      ],
    );
  }

  Widget _buildScrollableContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildBenefitsList(),
          SizedBox(height: 32.h), // Bottom padding
        ],
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
          _buildBook(), // Book for learning
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

  Widget _buildBook() {
    return Positioned(
      right: 15.w,
      bottom: 20.h,
      child: Container(
        width: 20.w,
        height: 16.h,
        decoration: BoxDecoration(
          color: Colors.brown[600],
          borderRadius: BorderRadius.circular(3.w),
        ),
      ),
    );
  }

  Widget _buildSpeechBubble() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 32.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(20.w),
      ),
      child: Column(
        children: [
          Text(
            'Và đây là những gì bạn có thể đạt được sau 3 tháng!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          CustomPaint(
            size: Size(20.w, 10.h),
            painter: TrianglePainter(),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsList() {
    final benefits = [
      (
        '💬',
        'Tự tin giao tiếp',
        'Luyện nghe nói không áp lực',
        Colors.purple[300]!,
      ),
      (
        '📖',
        'Xây dựng vốn từ',
        'Các từ và cụm từ phổ biến, thiết thực trong đời sống',
        Colors.blue[300]!,
      ),
      (
        '⏰',
        'Tạo thói quen học tập',
        'Nhắc nhở thông minh, thử thách vui nhộn và còn nhiều tính năng thú vị khác',
        Colors.orange[300]!,
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        children: benefits.map((benefit) {
          return Column(
            children: [
              _buildBenefitItem(
                benefit.$1, // icon
                benefit.$2, // title
                benefit.$3, // description
                benefit.$4, // color
              ),
              SizedBox(height: 24.h),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBenefitItem(
    String icon,
    String title,
    String description,
    Color iconColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon
        Container(
          width: 48.w,
          height: 48.h,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12.w),
          ),
          child: Center(
            child: Text(
              icon,
              style: TextStyle(fontSize: 24.sp),
            ),
          ),
        ),
        
        SizedBox(width: 16.w),
        
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[800]!
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, size.height);
    path.lineTo(0, 0);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}