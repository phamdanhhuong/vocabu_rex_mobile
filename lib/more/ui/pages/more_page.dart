import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/profile/ui/pages/profile_page.dart';
import 'package:vocabu_rex_mobile/pronunciation/ui/pages/pronunciation_page.dart';
import 'package:vocabu_rex_mobile/more/ui/pages/video_call_page.dart';
import 'package:vocabu_rex_mobile/more/ui/pages/practice_center_page.dart';

/// Widget More - Hiển thị bottom sheet với 4 lựa chọn
class More extends StatelessWidget {
  const More({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Auto show bottom sheet when this widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showMoreOptions(context);
    });

    return Container(
      color: AppColors.snow,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.apps, size: 64.sp, color: AppColors.macaw),
            SizedBox(height: 16.h),
            Text(
              'Thêm tùy chọn',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.bodyText,
                  ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Chọn một tùy chọn từ menu bên dưới',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.wolf,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  static void _showMoreOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const MoreSheet(),
    );
  }

  static Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.bodyText,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.wolf,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.wolf, size: 24.sp),
          ],
        ),
      ),
    );
  }
}

/// Public widget that renders the same bottom-sheet content used by `More`.
class MoreSheet extends StatelessWidget {
  final Function(int)? onOptionSelected;

  const MoreSheet({Key? key, this.onOptionSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.swan,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 8.h),

            // Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Text(
                'Thêm tùy chọn',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.bodyText,
                    ),
              ),
            ),

            // Options
            More._buildOption(
              context,
              icon: Icons.person,
              title: 'Hồ sơ',
              subtitle: 'Xem và chỉnh sửa hồ sơ của bạn',
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
              icon: Icons.record_voice_over,
              title: 'Phát âm',
              subtitle: 'Luyện tập phát âm tiếng Anh',
              color: AppColors.cardinal,
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
              icon: Icons.video_call,
              title: 'Cuộc gọi video',
              subtitle: 'Trò chuyện video với người bản ngữ',
              color: AppColors.featherGreen,
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
              subtitle: 'Các bài tập nâng cao kỹ năng',
              color: AppColors.bee,
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

            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}
