import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import '../models/onboarding_models.dart';

/// Character/image display with flexible positioning and speech bubble
class CharacterDisplay extends StatelessWidget {
  final String? imageUrl;      // URL của character image/gif
  final String? speechText;    // Text trong speech bubble
  final CharacterPosition position;
  final bool showSkipButton;
  final VoidCallback? onSkip;
  
  const CharacterDisplay({
    Key? key,
    this.imageUrl,
    this.speechText,
    this.position = CharacterPosition.top,
    this.showSkipButton = false,
    this.onSkip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final character = imageUrl != null
        ? Image.network(
            imageUrl!,
            height: 100.h,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to placeholder if image fails to load
              return Container(
                height: 100.h,
                width: 100.w,
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(50.w),
                ),
                child: Icon(
                  Icons.person,
                  size: 50.sp,
                  color: Colors.grey[500],
                ),
              );
            },
          )
        : const SizedBox.shrink();
    
    final speech = speechText != null
        ? Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.snow,
              borderRadius: BorderRadius.circular(16.w),
              border: Border.all(color: AppColors.swan, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.swan,
                  offset: const Offset(0, 2),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Text(
              speechText!,
              style: TextStyle(
                color: AppColors.bodyText,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
          )
        : const SizedBox.shrink();
    
    Widget content;
    switch (position) {
      case CharacterPosition.top:
        content = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (imageUrl != null) character,
            if (speechText != null && imageUrl != null) SizedBox(height: 16.h),
            if (speechText != null) speech,
          ],
        );
        break;
      
      case CharacterPosition.bottom:
        content = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (speechText != null) speech,
            if (speechText != null && imageUrl != null) SizedBox(height: 16.h),
            if (imageUrl != null) character,
          ],
        );
        break;
      
      case CharacterPosition.left:
        content = Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (imageUrl != null) character,
            if (imageUrl != null && speechText != null) SizedBox(width: 16.w),
            if (speechText != null) Expanded(child: speech),
          ],
        );
        break;
      
      case CharacterPosition.right:
        content = Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (speechText != null) Expanded(child: speech),
            if (imageUrl != null && speechText != null) SizedBox(width: 16.w),
            if (imageUrl != null) character,
          ],
        );
        break;
    }
    
    if (showSkipButton && onSkip != null) {
      return Stack(
        children: [
          content,
          Positioned(
            top: 0,
            right: 0,
            child: TextButton(
              onPressed: onSkip,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              ),
              child: Text(
                'Bỏ qua',
                style: TextStyle(
                  color: AppColors.wolf,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      );
    }
    
    return content;
  }
}
