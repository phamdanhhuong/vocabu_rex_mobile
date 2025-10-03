import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/constants/app_colors.dart';

class ExperienceLevelScreen extends StatelessWidget {
  final String? selectedLevel;
  final Function(String) onLevelSelected;

  const ExperienceLevelScreen({
    super.key,
    this.selectedLevel,
    required this.onLevelSelected,
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
          _buildLevelsList(),
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
          _buildBook(),
          _buildPencil(),
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
      right: 10.w,
      bottom: 15.h,
      child: Container(
        width: 25.w,
        height: 18.h,
        decoration: BoxDecoration(
          color: Colors.brown[600],
          borderRadius: BorderRadius.circular(4.w),
        ),
      ),
    );
  }

  Widget _buildPencil() {
    return Positioned(
      left: 10.w,
      bottom: 20.h,
      child: Container(
        width: 20.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: Colors.yellow,
          borderRadius: BorderRadius.circular(2.w),
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
            'Trình độ tiếng Anh của bạn ở mức nào?',
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

  Widget _buildLevelsList() {
    final levels = [
      ('📊', 'Tôi mới học tiếng Anh', 'beginner', 1),
      ('📊', 'Tôi biết một vài từ thông dụng', 'elementary', 2),
      ('📊', 'Tôi có thể giao tiếp cơ bản', 'intermediate', 3),
      ('📊', 'Tôi có thể nói về nhiều chủ đề', 'upper_intermediate', 4),
      ('📊', 'Tôi có thể đi sâu vào hầu hết các chủ đề', 'advanced', 5),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        children: levels.map((level) {
          return Column(
            children: [
              _buildLevelOption(level.$1, level.$2, level.$3, level.$4),
              SizedBox(height: 16.h),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLevelOption(String icon, String title, String value, int level) {
    final isSelected = selectedLevel == value;
    return GestureDetector(
      onTap: () => onLevelSelected(value),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(16.w),
          border: isSelected 
            ? Border.all(color: AppColors.primaryBlue, width: 2)
            : null,
        ),
        child: Row(
          children: [
            // Progress bars
            Column(
              children: List.generate(5, (index) {
                return Container(
                  margin: EdgeInsets.only(bottom: 2.h),
                  width: 6.w,
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: index < level ? AppColors.primaryBlue : Colors.grey[600],
                    borderRadius: BorderRadius.circular(3.w),
                  ),
                );
              }),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
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