import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

class WelcomeButtons extends StatefulWidget {
  const WelcomeButtons({super.key});

  @override
  State<WelcomeButtons> createState() => _WelcomeButtonsState();
}

class _WelcomeButtonsState extends State<WelcomeButtons> {
  bool _pressedGetStarted = false;
  bool _pressedLogin = false;
  static const Duration _pressDuration = Duration(milliseconds: 90);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        children: [
          // Get Started button
          FadeInUp(
            delay: const Duration(milliseconds: 600),
            child: GestureDetector(
              onTapDown: (_) => setState(() => _pressedGetStarted = true),
            onTapUp: (_) => setState(() => _pressedGetStarted = false),
            onTapCancel: () => setState(() => _pressedGetStarted = false),
            onTap: () {
              Navigator.pushNamed(context, '/onboarding');
            },
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: _pressDuration,
              curve: Curves.easeOut,
              transform: Matrix4.translationValues(
                  0, _pressedGetStarted ? 4.0 : 0.0, 0),
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              decoration: BoxDecoration(
                color: AppColors.featherGreen,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: _pressedGetStarted
                        ? Colors.transparent
                        : AppColors.wingOverlay,
                    offset: _pressedGetStarted
                        ? Offset.zero
                        : const Offset(0, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Text(
                'GET STARTED',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.snow,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          ),

          SizedBox(height: 16.h),

          // Login button
          FadeInUp(
            delay: const Duration(milliseconds: 800),
            child: GestureDetector(
              onTapDown: (_) => setState(() => _pressedLogin = true),
            onTapUp: (_) => setState(() => _pressedLogin = false),
            onTapCancel: () => setState(() => _pressedLogin = false),
            onTap: () {
              Navigator.pushNamed(context, '/login');
            },
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: _pressDuration,
              curve: Curves.easeOut,
              transform:
                  Matrix4.translationValues(0, _pressedLogin ? 4.0 : 0.0, 0),
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              decoration: BoxDecoration(
                color: AppColors.snow,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: AppColors.swan,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _pressedLogin
                        ? Colors.transparent
                        : AppColors.swan,
                    offset: _pressedLogin
                        ? Offset.zero
                        : const Offset(0, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Text(
                'I ALREADY HAVE AN ACCOUNT',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.macaw,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          ),

          SizedBox(height: 30.h),
        ],
      ),
    );
  }
}
