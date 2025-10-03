import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/constants/app_colors.dart';

class AssessmentScreen extends StatefulWidget {
  final Function(String) onAssessmentSelected;

  const AssessmentScreen({
    super.key,
    required this.onAssessmentSelected,
  });

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  String? selectedOption;

  // Global key for external access
  static _AssessmentScreenState? _instance;

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

  Widget _buildDuoCharacter() {
    return Container(
      width: 120.w,
      height: 120.h,
      decoration: const BoxDecoration(
        color: Color(0xFF58CC02),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '🦉',
          style: TextStyle(
            fontSize: 60.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildSpeechBubble() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 32.w),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(20.w),
            ),
            child: Text(
              'Tôi muốn đánh giá khả năng tiếng Anh hiện tại của bạn!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Triangle pointer
          Positioned(
            top: -8.h,
            left: 40.w,
            child: CustomPaint(
              painter: TrianglePainter(),
              size: Size(16.w, 8.h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollableContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildAssessmentOptions(),
          SizedBox(height: 24.h),
          _buildSkipButton(),
          SizedBox(height: 32.h), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildAssessmentOptions() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        children: [
          // Test đánh giá option
          _buildAssessmentOption(
            icon: '📝',
            title: 'Tôi muốn làm bài test đánh giá',
            description: 'Làm bài test ngắn để đánh giá chính xác trình độ hiện tại của bạn (5-10 phút)',
            buttonText: 'Bắt đầu',
            value: 'assessment',
            hasBlueAccent: true,
          ),
          
          SizedBox(height: 16.h),
          
          // Beginner option
          _buildAssessmentOption(
            icon: '🌱',
            title: 'Tôi là người mới bắt đầu',
            description: 'Tôi chưa có kiến thức gì về tiếng Anh hoặc chỉ biết một chút cơ bản',
            value: 'beginner',
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentOption({
    required String icon,
    required String title,
    required String description,
    String? buttonText,
    required String value,
    bool hasBlueAccent = false,
  }) {
    final isSelected = selectedOption == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedOption = value;
        });
        widget.onAssessmentSelected(value);
      },
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(16.w),
          border: isSelected
            ? Border.all(color: AppColors.primaryBlue, width: 2.w)
            : (hasBlueAccent 
                ? Border.all(color: AppColors.primaryBlue.withOpacity(0.5), width: 1.w)
                : null),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: isSelected
                  ? AppColors.primaryBlue.withOpacity(0.3)
                  : (hasBlueAccent 
                      ? AppColors.primaryBlue.withOpacity(0.2)
                      : Colors.orange.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(10.w),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: TextStyle(fontSize: 20.sp),
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
                      color: isSelected
                        ? AppColors.primaryBlue 
                        : (hasBlueAccent ? AppColors.primaryBlue : Colors.white),
                      fontSize: 16.sp,
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
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            
            // Selection indicator
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primaryBlue,
                size: 24.sp,
              ),
            
            // Button (only for first option and not selected)
            if (buttonText != null && !isSelected)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 8.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20.w),
                ),
                child: Text(
                  buttonText,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    final isSelected = selectedOption == 'skip';
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedOption = 'skip';
          });
          widget.onAssessmentSelected('skip');
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16.w),
            border: Border.all(
              color: isSelected ? AppColors.primaryBlue : Colors.grey[600]!, 
              width: isSelected ? 2.w : 1.w,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Tạm thời bỏ qua',
                style: TextStyle(
                  color: isSelected ? AppColors.primaryBlue : Colors.grey[400],
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (isSelected)
                SizedBox(width: 8.w),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppColors.primaryBlue,
                  size: 20.sp,
                ),
            ],
          ),
        ),
      ),
    );
  }

  bool get hasSelectedOption => selectedOption != null;
  String? get selectedAssessment => selectedOption;
  
  void handleContinue() {
    if (selectedOption != null) {
      widget.onAssessmentSelected(selectedOption!);
    }
  }
}

// Custom painter for triangle
class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[800]!
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}