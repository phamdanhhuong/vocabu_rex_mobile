import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

/// Section hiển thị danh sách thành tích
class ProfileAchievements extends StatelessWidget {
  const ProfileAchievements({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Dữ liệu giả cho thành tích
    final achievements = [
      {'path': 'assets/images/badge1.png', 'level': '10'},
      {'path': 'assets/images/badge2.png', 'level': '100'},
      {'path': 'assets/images/badge3.png', 'level': '3'},
    ];

    return Container(
      height: 150.h, // Chiều cao cố định cho list ngang
      padding: EdgeInsets.only(left: 16.w, top: 8.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: achievements.length,
        itemBuilder: (context, index) {
          final ach = achievements[index];
          return Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  width: 100.w,
                  height: 100.w,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.swan, width: 1.5.w),
                    color: AppColors.snow,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Image.asset(
                      ach['path']!,
                      width: 100.w,
                      height: 100.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Nhãn level
                Positioned(
                  bottom: 8.h,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      ach['level']!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.snow,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
