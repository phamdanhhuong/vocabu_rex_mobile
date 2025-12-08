import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/app_button.dart';
import 'package:vocabu_rex_mobile/theme/widgets/speech_bubbles/speech_bubble.dart';

class RedoPhaseTransitionPage extends StatelessWidget {
  final VoidCallback onContinue;

  const RedoPhaseTransitionPage({
    super.key,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(),
                
                // Character with speech bubble
                Column(
                  children: [
                    // Speech bubble
                    SpeechBubble(
                      variant: SpeechBubbleVariant.defaults,
                      tailDirection: SpeechBubbleTailDirection.bottom,
                      tailOffset: 100.0,
                      child: Column(
                        children: [
                          Text(
                            'Làm lại những câu bạn đã sai nhé,\nkhông mất năng lượng đâu!',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: AppColors.eel,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.favorite,
                                color: AppColors.cardinal,
                                size: 18.sp,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                'Miễn phí',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.featherGreen,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    // Character (Duo owl)
                    Container(
                      width: 200.w,
                      height: 200.h,
                      decoration: BoxDecoration(
                        color: AppColors.featherGreen.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '🦉',
                          style: TextStyle(fontSize: 120.sp),
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 40.h),
                
                Spacer(),
                
                // Continue Button
                AppButton(
                  label: 'BẮT ĐẦU',
                  onPressed: onContinue,
                  variant: ButtonVariant.primary,
                  size: ButtonSize.large,
                ),
                
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Future<void> show(BuildContext context, VoidCallback onContinue) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RedoPhaseTransitionPage(onContinue: onContinue),
        fullscreenDialog: true,
      ),
    );
  }
}
