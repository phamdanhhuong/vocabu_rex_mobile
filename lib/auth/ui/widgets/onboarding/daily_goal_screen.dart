import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/constants/app_colors.dart';

class DailyGoalScreen extends StatelessWidget {
  final String? selectedGoal;
  final Function(String) onGoalSelected;

  const DailyGoalScreen({
    super.key,
    this.selectedGoal,
    required this.onGoalSelected,
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
          _buildGoalsList(),
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
            'Tuyệt vời! Bây giờ, bạn muốn dành bao nhiều thời gian mỗi ngày?',
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

  Widget _buildGoalsList() {
    final goals = [
      ('5 phút/ngày', 'Thư giãn', 'casual'),
      ('10 phút/ngày', 'Đều đặn', 'regular'),
      ('15 phút/ngày', 'Nghiêm túc', 'serious'),
      ('20 phút/ngày', 'Cường độ cao', 'intense'),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        children: goals.map((goal) {
          return Column(
            children: [
              _buildGoalOption(goal.$1, goal.$2, goal.$3),
              SizedBox(height: 16.h),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGoalOption(String time, String difficulty, String value) {
    final isSelected = selectedGoal == value;
    return GestureDetector(
      onTap: () => onGoalSelected(value),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(16.w),
          border: isSelected 
            ? Border.all(color: AppColors.primaryBlue, width: 2)
            : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    time,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    difficulty,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check,
                color: AppColors.primaryBlue,
                size: 24.sp,
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