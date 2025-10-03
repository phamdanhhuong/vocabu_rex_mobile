import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DuolingoCharacter extends StatelessWidget {
  final Color backgroundColor;
  final double size;
  final Color eyeColor;
  final Color skinColor;

  const DuolingoCharacter({
    super.key,
    required this.backgroundColor,
    required this.size,
    required this.eyeColor,
    required this.skinColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: _buildCharacterFace(eyeColor, skinColor),
    );
  }

  Widget _buildCharacterFace(Color eyeColor, Color skinColor) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Face base
        Container(
          width: 50.w,
          height: 50.h,
          decoration: BoxDecoration(
            color: skinColor,
            shape: BoxShape.circle,
          ),
        ),
        // Eyes
        Positioned(
          top: 15.h,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8.w,
                height: 8.h,
                decoration: BoxDecoration(
                  color: eyeColor,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 6.w),
              Container(
                width: 8.w,
                height: 8.h,
                decoration: BoxDecoration(
                  color: eyeColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
        // Smile
        Positioned(
          bottom: 15.h,
          child: Container(
            width: 16.w,
            height: 8.h,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: eyeColor,
                  width: 2,
                ),
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8.r),
                bottomRight: Radius.circular(8.r),
              ),
            ),
          ),
        ),
      ],
    );
  }
}