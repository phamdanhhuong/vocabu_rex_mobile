import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/achievement/ui/blocs/achievement_bloc.dart';
import 'package:vocabu_rex_mobile/achievement/domain/entities/achievement_entity.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/core/app_preferences.dart';

/// Section hiển thị danh sách thành tích
class ProfileAchievements extends StatefulWidget {
  const ProfileAchievements({super.key});

  @override
  State<ProfileAchievements> createState() => _ProfileAchievementsState();
}

class _ProfileAchievementsState extends State<ProfileAchievements> {
  @override
  void initState() {
    super.initState();
    // Load achievements when widget is initialized
    context.read<AchievementBloc>().add(LoadAchievementsSummaryEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: AppPreferences(),
      builder: (context, _) {
        return BlocBuilder<AchievementBloc, AchievementState>(
          builder: (context, state) {
            List achievements = [];

        if (state is AchievementLoaded) {
          // Lấy 3 thành tích đầu tiên
          achievements = (state.awardsAchievements ?? []).take(3).toList();
        }

        if (achievements.isEmpty) {
          return Container(
            height: 150.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Center(
              child: Text(
                'Chưa có thành tích',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.wolf,
                ),
              ),
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            decoration: BoxDecoration(
              color: AppColors.snow,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.swan, width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int i = 0; i < achievements.length; i++) ...[
                  Expanded(
                    child: _buildBadgeItem(achievements[i]),
                  ),
                  if (i < achievements.length - 1)
                    Container(height: 60.h, width: 1.w, color: AppColors.swan),
                ],
              ],
            ),
          ),
        );
      },
    );
  });
}

  Widget _buildBadgeItem(dynamic achievement) {
    String badgeAsset = AchievementAssetHelper.resolveAssetPath(achievement);
    final isLocked = !achievement.isUnlocked && achievement.progress == 0;

    const greyscaleMatrix = <double>[
      0.2126, 0.7152, 0.0722, 0, 0,
      0.2126, 0.7152, 0.0722, 0, 0,
      0.2126, 0.7152, 0.0722, 0, 0,
      0,      0,      0,      1, 0,
    ];

    Widget img = Image.asset(
      badgeAsset,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          achievement.achievement?.categoryIcon ?? 'assets/icons/reward.png',
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Icon(
            Icons.emoji_events,
            size: 40.w,
            color: AppColors.wolf,
          ),
        );
      },
    );

    if (isLocked) {
      img = ColorFiltered(
        colorFilter: const ColorFilter.matrix(greyscaleMatrix),
        child: Opacity(opacity: 0.4, child: img),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: AspectRatio(
        aspectRatio: 1,
        child: img,
      ),
    );
  }
}
