import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/achievement/ui/blocs/achievement_bloc.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

/// Section hiển thị danh sách thành tích
class ProfileAchievements extends StatefulWidget {
  const ProfileAchievements({Key? key}) : super(key: key);

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

    return BlocBuilder<AchievementBloc, AchievementState>(
      builder: (context, state) {
        List achievements = [];

        if (state is AchievementLoaded) {
          // Get awards achievements (not personal) and take first 3
          achievements = (state.awardsAchievements ?? []).take(3).toList();
        }

        // Show empty state if no achievements
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

        return Container(
          height: 130.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.snow,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: AppColors.swan, width: 1.5.w),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < achievements.length; i++) ...[
                  Builder(
                    builder: (context) {
                      final achievement = achievements[i];
                      
                      // Normalize achievement name to match asset naming pattern
                      String normalizeAssetName(String name) {
                        String normalized = name.toLowerCase().replaceAll(' ', '_');
                        normalized = normalized.replaceAll(RegExp(r'_t[0-9]+$'), '');
                        normalized = normalized.replaceAll(RegExp(r'_[0-9]+$'), '');
                        return normalized;
                      }

                      // Determine badge asset based on progress
                      String getBadgeAsset() {
                        final requirement = achievement.achievement?.requirement ?? 0;
                        final isFull = requirement > 0 && achievement.progress >= requirement;
                        final suffix = isFull ? '_done.png' : '_doing.png';
                        String baseName = normalizeAssetName(achievement.achievement?.name ?? '');
                        return 'assets/achivements/$baseName$suffix';
                      }

                      final isLocked = !achievement.isUnlocked && achievement.progress == 0;

                      // Grayscale color filter matrix
                      const greyscaleMatrix = <double>[
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0, 0, 0, 1, 0,
                      ];

                      Widget buildBadge() {
                        final badgeAsset = getBadgeAsset();
                        Widget img = Image.asset(
                          badgeAsset,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              achievement.achievement?.categoryIcon ?? 'assets/achivements/default.png',
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) {
                                return Icon(
                                  Icons.emoji_events,
                                  size: 40.w,
                                  color: AppColors.wolf,
                                );
                              },
                            );
                          },
                        );

                        if (isLocked) {
                          return ColorFiltered(
                            colorFilter: const ColorFilter.matrix(greyscaleMatrix),
                            child: Opacity(opacity: 0.4, child: img),
                          );
                        }

                        return img;
                      }

                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          clipBehavior: Clip.none,
                          children: [
                            SizedBox(
                              width: 80.w,
                              height: 80.w,
                              child: buildBadge(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  // Add divider between achievements (but not after the last one)
                  if (i < achievements.length - 1)
                    Container(
                      height: 80.h,
                      width: 1.w,
                      color: AppColors.swan,
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
