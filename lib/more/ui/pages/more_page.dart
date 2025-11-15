import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/profile/ui/pages/profile_page.dart';
import 'package:vocabu_rex_mobile/pronunciation/ui/pages/pronunciation_page.dart';
import 'package:vocabu_rex_mobile/more/ui/pages/video_call_page.dart';
import 'package:vocabu_rex_mobile/more/ui/pages/practice_center_page.dart';

/// Widget More - Hiển thị dropdown với 4 lựa chọn (giống energy dropdown)
class More extends StatelessWidget {
  const More({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Placeholder - Modal sẽ được hiển thị từ AppBottomNav
    return Container(
      color: AppColors.snow,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.apps, size: 64.sp, color: AppColors.macaw),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  /// 
  /// BUILD OPTION ĐÃ ĐƯỢC CẬP NHẬT
  /// 
  /// Đã loại bỏ:
  /// - `subtitle` parameter
  /// - `Text(subtitle, ...)`
  /// - `Icon(Icons.chevron_right, ...)`
  /// 
  static Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    // required String subtitle, // --- Đã loại bỏ
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: Row(
          children: [
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(icon, color: color, size: 28.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text( // --- Đã thay thế Column bằng Text
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.bodyText,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Icon(Icons.chevron_right, ...), // --- Đã loại bỏ
          ],
        ),
      ),
    );
  }
}

/// Dropdown content cho More (giống energy dropdown - không có bubble)
class MoreSheet extends StatelessWidget {
  final Function(int)? onOptionSelected;

  const MoreSheet({Key? key, this.onOptionSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.snow, // Nền trắng
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Options
          More._buildOption(
            context,
            icon: Icons.person_outline,
            title: 'Hồ sơ',
            color: AppColors.macaw,
            onTap: () {
              if (onOptionSelected != null) {
                onOptionSelected!(6); // Index for ProfilePage
              } else {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              }
            },
          ),

          More._buildOption(
            context,
            icon: Icons.sentiment_satisfied_alt,
            title: 'Phát âm',
            color: AppColors.macaw,
            onTap: () {
              if (onOptionSelected != null) {
                onOptionSelected!(7); // Index for PronunciationPage
              } else {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PronunciationPage()),
                );
              }
            },
          ),

          More._buildOption(
            context,
            icon: Icons.videocam_rounded,
            title: 'Cuộc gọi video',
            color: Colors.purple,
            onTap: () {
              if (onOptionSelected != null) {
                onOptionSelected!(8); // Index for VideoCallPage
              } else {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const VideoCallPage()),
                );
              }
            },
          ),

          More._buildOption(
            context,
            icon: Icons.fitness_center,
            title: 'Trung tâm luyện tập',
            color: AppColors.macaw,
            onTap: () {
              if (onOptionSelected != null) {
                onOptionSelected!(9); // Index for PracticeCenterPage
              } else {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PracticeCenterPage()),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}