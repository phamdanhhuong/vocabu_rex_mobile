import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';

class WelcomeText extends StatelessWidget {
  const WelcomeText({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: FadeInUp(
        delay: const Duration(milliseconds: 400),
        child: Text(
          'The free, fun, and effective way to learn a language!',
          textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 32.sp,
          fontWeight: FontWeight.w800,
          color: Colors.grey[700],
          height: 1.2,
          letterSpacing: -0.5,
        ),
      ),
      ),
    );
  }
}
