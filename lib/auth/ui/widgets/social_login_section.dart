import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/constants/app_colors.dart';

class SocialLoginSection extends StatelessWidget {
  const SocialLoginSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Phone login
        _buildPhoneLoginButton(),
        SizedBox(height: 16.h),
        // Social login buttons row
        _buildSocialLoginRow(),
      ],
    );
  }

  Widget _buildPhoneLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: OutlinedButton.icon(
        onPressed: () {
          // Handle phone login
        },
        icon: Icon(
          Icons.phone,
          color: Color(0xFF4FC3F7),
          size: 24.sp,
        ),
        label: Text(
          'ĐĂNG NHẬP ĐIỆN THOẠI',
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Color(0xFF4A5A6C)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialLoginRow() {
    return Row(
      children: [
        // Facebook button
        Expanded(
          child: _buildFacebookButton(),
        ),
        SizedBox(width: 16.w),
        // Google button
        Expanded(
          child: _buildGoogleButton(),
        ),
      ],
    );
  }

  Widget _buildFacebookButton() {
    return SizedBox(
      height: 56.h,
      child: OutlinedButton.icon(
        onPressed: () {
          // Handle Facebook login
        },
        icon: Icon(
          Icons.facebook,
          color: Color(0xFF4267B2),
          size: 24.sp,
        ),
        label: Text(
          'FACEBOOK',
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Color(0xFF4A5A6C)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      height: 56.h,
      child: OutlinedButton.icon(
        onPressed: () {
          // Handle Google login
        },
        icon: Text(
          'G',
          style: TextStyle(
            color: Color(0xFFDB4437),
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        label: Text(
          'GOOGLE',
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Color(0xFF4A5A6C)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
      ),
    );
  }
}