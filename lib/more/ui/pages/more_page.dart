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
    required String iconAsset,
    required String title,
    required Color color,
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);

    final BoxDecoration iconDecoration = isSelected
        ? BoxDecoration(
            color: AppColors.selectionBlueLight,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppColors.macaw,
              width: 2,
            ),
          )
        : BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          );

    return InkWell(
      onTap: onTap,
      child: Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppColors.swan,
              width: 2.h,
            ),
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48.w,
              height: 48.w,
              decoration: iconDecoration,
              padding: EdgeInsets.all(4.w),
              child: Image.asset(
                iconAsset,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.bodyText,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dropdown content cho More (giống energy dropdown - không có bubble)
class MoreSheet extends StatelessWidget {
  final Function(int)? onOptionSelected;
  final int? currentSelectedIndex;

  const MoreSheet({
    Key? key,
    this.onOptionSelected,
    this.currentSelectedIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background, // Nền trắng
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Options
          More._buildOption(
            context,
            iconAsset: 'assets/icons/profile.png',
            title: 'Hồ sơ',
            color: AppColors.background,
            isSelected: currentSelectedIndex == 6,
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
            iconAsset: 'assets/icons/speech.png',
            title: 'Phát âm',
            color: AppColors.background,
            isSelected: currentSelectedIndex == 7,
            onTap: () {
              if (onOptionSelected != null) {
                onOptionSelected!(7); // Index for PronunciationPage
              } else {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PronunciationPage(),
                  ),
                );
              }
            },
          ),

          More._buildOption(
            context,
            iconAsset: 'assets/icons/video_call.png',
            title: 'Cuộc gọi video',
            color: AppColors.background,
            isSelected: currentSelectedIndex == 8,
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
            iconAsset: 'assets/icons/review.png',
            title: 'Trung tâm luyện tập',
            color: AppColors.background,
            isSelected: currentSelectedIndex == 9,
            onTap: () {
              if (onOptionSelected != null) {
                onOptionSelected!(9); // Index for PracticeCenterPage
              } else {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PracticeCenterPage(),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}