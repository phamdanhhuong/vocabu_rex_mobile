import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/feed/ui/utils/feed_tokens.dart';

class FeedStickyPrompt extends StatelessWidget {
  const FeedStickyPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: FeedTokens.cardMarginHorizontal,
        vertical: FeedTokens.cardMarginVertical,
      ),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.macawLight,
        borderRadius: BorderRadius.circular(FeedTokens.radiusL),
        border: Border.all(color: AppColors.macaw, width: 2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hôm nay bạn đã làm gì? 🔥',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                    color: AppColors.eel,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Khoe thành tích với bạn bè ngay!',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.hare,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Pulse(
            infinite: true,
            duration: const Duration(seconds: 2),
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tính năng đăng bài đang phát triển!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.macaw,
                foregroundColor: AppColors.snow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                elevation: 4,
              ),
              child: const Text('Chia sẻ', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
