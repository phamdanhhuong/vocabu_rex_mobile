import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

class TermsAndPrivacy extends StatelessWidget {
  const TermsAndPrivacy({super.key});

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      delay: const Duration(milliseconds: 1000),
      child: Padding(
        padding: EdgeInsets.only(bottom: 30.h),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(color: AppColors.wolf, fontSize: 12.sp, height: 1.4),
          children: [
            TextSpan(text: 'Khi đăng ký trên Vocaburex, bạn đã đồng ý với '),
            TextSpan(
              text: 'Các chính sách',
              style: TextStyle(
                color: Color(0xFF4FC3F7),
                decoration: TextDecoration.underline,
              ),
            ),
            TextSpan(text: ' và '),
            TextSpan(
              text: 'Chính sách bảo mật',
              style: TextStyle(
                color: Color(0xFF4FC3F7),
                decoration: TextDecoration.underline,
              ),
            ),
            TextSpan(text: ' của chúng tôi.'),
          ],
        ),
      ),
      ),
    );
  }
}
