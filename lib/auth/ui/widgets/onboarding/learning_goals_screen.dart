import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/constants/app_colors.dart';

class LearningGoalsScreen extends StatelessWidget {
  final List<String> selectedGoals;
  final Function(String) onGoalToggled;

  const LearningGoalsScreen({
    super.key,
    required this.selectedGoals,
    required this.onGoalToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20.h),
        
        // Duo character
        Container(
          width: 120.w,
          height: 120.h,
          decoration: BoxDecoration(
            color: AppColors.primaryGreen,
            borderRadius: BorderRadius.circular(60.w),
            border: Border.all(color: Colors.grey[800]!, width: 4),
          ),
          child: Stack(
            children: [
              // Main head
              Container(
                width: 120.w,
                height: 120.h,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(60.w),
                ),
              ),
              // Eyes
              Positioned(
                left: 25.w,
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
              ),
              Positioned(
                right: 25.w,
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
              ),
              // Beak
              Positioned(
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
              ),
            ],
          ),
        ),
        
        SizedBox(height: 40.h),
        
        // Speech bubble
        Container(
          margin: EdgeInsets.symmetric(horizontal: 32.w),
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(20.w),
          ),
          child: Column(
            children: [
              Text(
                'Đó đều là những lý do học tập tuyệt vời!',
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
        ),
        
        SizedBox(height: 32.h),
        
        // Goals title
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Text(
            'Tôi muốn học Tiếng Anh để...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        
        SizedBox(height: 24.h),
        
        // Goal options
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            children: [
              _buildGoalOption('🎓', 'Học tập ở trường', 'study'),
              SizedBox(height: 16.h),
              _buildGoalOption('✈️', 'Du lịch', 'travel'),
              SizedBox(height: 16.h),
              _buildGoalOption('👨‍👩‍👧‍👦', 'Giao tiếp với gia đình', 'family'),
              SizedBox(height: 16.h),
              _buildGoalOption('🌍', 'Văn hóa', 'culture'),
              SizedBox(height: 16.h),
              _buildGoalOption('🎮', 'Giải trí', 'entertainment'),
              SizedBox(height: 16.h),
              _buildGoalOption('💼', 'Phát triển sự nghiệp', 'career'),
              SizedBox(height: 16.h),
              _buildGoalOption('🧠', 'Tận dụng thời gian rảnh', 'free_time'),
            ],
          ),
        ),
        
        SizedBox(height: 32.h),
      ],
    );
  }

  Widget _buildGoalOption(String icon, String title, String value) {
    final isSelected = selectedGoals.contains(value);
    return GestureDetector(
      onTap: () => onGoalToggled(value),
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
            Text(
              icon,
              style: TextStyle(fontSize: 24.sp),
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