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
              SizedBox(height: 20.h),
              // Duo character with book
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
              // Book in hand
              Positioned(
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
              ),
              // Pencil
              Positioned(
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
                'Trình độ tiếng Anh của bạn ở mức nào?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              // Triangle pointer
              CustomPaint(
                size: Size(20.w, 10.h),
                painter: TrianglePainter(),
              ),
            ],
          ),
        ),
        
        SizedBox(height: 60.h),
        
        // Experience level options
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            children: [
              _buildLevelOption(
                '📊',
                'Tôi mới học tiếng Anh',
                'beginner',
                1,
              ),
              SizedBox(height: 16.h),
              _buildLevelOption(
                '📊',
                'Tôi biết một vài từ thông dụng',
                'elementary',
                2,
              ),
              SizedBox(height: 16.h),
              _buildLevelOption(
                '📊',
                'Tôi có thể giao tiếp cơ bản',
                'intermediate',
                3,
              ),
              SizedBox(height: 16.h),
              _buildLevelOption(
                '📊',
                'Tôi có thể nói về nhiều chủ đề',
                'upper_intermediate',
                4,
              ),
              SizedBox(height: 16.h),
              _buildLevelOption(
                '📊',
                'Tôi có thể đi sâu vào hầu hết các chủ đề',
                'advanced',
                5,
              ),
              SizedBox(height: 32.h), // Extra space for button
            ],
          ),
        ),
      ],
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