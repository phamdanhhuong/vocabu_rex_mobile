import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/profile/ui/widgets/friend_streak_circle.dart';

/// Section hiển thị streak bạn bè
class ProfileFriendStreak extends StatelessWidget {
  const ProfileFriendStreak({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.snow,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.swan, width: 2.w),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title inside the same rounded card so the border encloses it
            Text(
              'Streak bạn bè',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.bodyText,
              ),
            ),
            SizedBox(height: 8.h),
            // Use LayoutBuilder for responsive circle sizing
            LayoutBuilder(
              builder: (context, constraints) {
                // Calculate available width for circles
                final availableWidth = constraints.maxWidth;
                final circleSize = (availableWidth - 40.w) / 5; // 5 circles with spacing
                final safeCircleSize = circleSize.clamp(44.0, 60.0); // Min 44, max 60
                
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FriendStreakCircle(
                      size: safeCircleSize.w,
                      isToday: true,
                      child: Text(
                        '0',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: AppColors.macaw,
                          fontWeight: FontWeight.bold,
                          fontSize: (safeCircleSize * 0.32).sp, // Scale font with circle
                        ),
                      ),
                    ),
                    FriendStreakCircle(
                      size: safeCircleSize.w,
                      child: Icon(
                        Icons.add,
                        color: AppColors.wolf,
                        size: (safeCircleSize * 0.44).sp,
                      ),
                    ),
                    FriendStreakCircle(
                      size: safeCircleSize.w,
                      child: Icon(
                        Icons.add,
                        color: AppColors.wolf,
                        size: (safeCircleSize * 0.44).sp,
                      ),
                    ),
                    FriendStreakCircle(
                      size: safeCircleSize.w,
                      child: Icon(
                        Icons.add,
                        color: AppColors.wolf,
                        size: (safeCircleSize * 0.44).sp,
                      ),
                    ),
                    FriendStreakCircle(
                      size: safeCircleSize.w,
                      child: Icon(
                        Icons.add,
                        color: AppColors.wolf,
                        size: (safeCircleSize * 0.44).sp,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
