import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/constants/app_colors.dart';

class LanguageSelectionScreen extends StatelessWidget {
  final String? selectedLanguage;
  final Function(String) onLanguageSelected;

  const LanguageSelectionScreen({
    super.key,
    this.selectedLanguage,
    required this.onLanguageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
                'Bạn muốn học gì nhỉ?',
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
        
        SizedBox(height: 40.h),
        
        Text(
          'Dành cho người nói tiếng Việt',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        
        SizedBox(height: 20.h),
        
        // Language options
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Column(
              children: [
                _buildLanguageOption(
                  '🇺🇸',
                  'Tiếng Anh',
                  'english',
                ),
                SizedBox(height: 16.h),
                _buildLanguageOption(
                  '🇨🇳',
                  'Tiếng Hoa',
                  'chinese',
                ),
                SizedBox(height: 16.h),
                _buildLanguageOption(
                  '🇮🇹',
                  'Tiếng Ý',
                  'italian',
                ),
                SizedBox(height: 16.h),
                _buildLanguageOption(
                  '🇫🇷',
                  'Tiếng Pháp',
                  'french',
                ),
                SizedBox(height: 16.h),
                _buildLanguageOption(
                  '🇰🇷',
                  'Tiếng Hàn',
                  'korean',
                ),
                SizedBox(height: 16.h),
                _buildLanguageOption(
                  '🇯🇵',
                  'Tiếng Nhật',
                  'japanese',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageOption(String flag, String language, String value) {
    final isSelected = selectedLanguage == value;
    return GestureDetector(
      onTap: () => onLanguageSelected(value),
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
              flag,
              style: TextStyle(fontSize: 24.sp),
            ),
            SizedBox(width: 16.w),
            Text(
              language,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
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