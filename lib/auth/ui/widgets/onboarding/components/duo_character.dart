import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/constants/app_colors.dart';

enum DuoCharacterType {
  normal,      // Chỉ có mắt và mỏ
  withBook,    // Có thêm cuốn sách (cho learning benefits)
  withGrad,    // Có mũ tốt nghiệp (cho assessment)
  happy,       // Vui vẻ (cho profile setup)
}

class DuoCharacter extends StatelessWidget {
  final DuoCharacterType type;
  final double? width;
  final double? height;

  const DuoCharacter({
    super.key,
    this.type = DuoCharacterType.normal,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final w = width ?? 120.w;
    final h = height ?? 120.h;
    
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(w / 2),
        border: Border.all(color: Colors.grey[800]!, width: 4),
      ),
      child: Stack(
        children: [
          Container(
            width: w,
            height: h,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.circular(w / 2),
            ),
          ),
          // Left eye
          _buildEye(left: w * 0.21, top: h * 0.29),
          // Right eye  
          _buildEye(right: w * 0.21, top: h * 0.29),
          // Beak
          _buildBeak(w, h),
          // Additional elements based on type
          if (type == DuoCharacterType.withBook) _buildBook(w, h),
          if (type == DuoCharacterType.withGrad) _buildGraduationCap(w, h),
          if (type == DuoCharacterType.happy) _buildHappyElements(w, h),
        ],
      ),
    );
  }

  Widget _buildEye({double? left, double? right, required double top}) {
    final eyeWidth = (width ?? 120.w) * 0.15;
    final eyeHeight = (height ?? 120.h) * 0.2;
    
    return Positioned(
      left: left,
      right: right,
      top: top,
      child: Container(
        width: eyeWidth,
        height: eyeHeight,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: Center(
          child: Container(
            width: eyeWidth * 0.44,
            height: eyeHeight * 0.48,
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.all(Radius.circular(6)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBeak(double w, double h) {
    return Positioned(
      left: w * 0.43,
      top: h * 0.54,
      child: Container(
        width: w * 0.13,
        height: h * 0.1,
        decoration: const BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildBook(double w, double h) {
    return Positioned(
      right: w * 0.125,
      bottom: h * 0.17,
      child: Container(
        width: w * 0.17,
        height: h * 0.13,
        decoration: BoxDecoration(
          color: Colors.brown[600],
          borderRadius: BorderRadius.circular(3.w),
        ),
        child: Center(
          child: Container(
            width: w * 0.1,
            height: 2.h,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildGraduationCap(double w, double h) {
    return Positioned(
      top: -h * 0.08,
      left: w * 0.2,
      child: Container(
        width: w * 0.6,
        height: h * 0.15,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(4.w),
        ),
        child: Center(
          child: Container(
            width: w * 0.05,
            height: w * 0.05,
            decoration: const BoxDecoration(
              color: Colors.yellow,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHappyElements(double w, double h) {
    return Positioned(
      top: h * 0.7,
      left: w * 0.3,
      child: Container(
        width: w * 0.4,
        height: h * 0.1,
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(w * 0.2),
        ),
      ),
    );
  }
}