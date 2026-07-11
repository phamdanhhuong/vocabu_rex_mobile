import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/leaderboard/domain/entities/leaderboard_standing_entity.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/profile/ui/pages/public_profile_page.dart';
import 'package:vocabu_rex_mobile/profile/ui/widgets/avatar_display.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shimmer/shimmer.dart';

class LeaderboardTile extends StatelessWidget {
  final LeaderboardStandingEntity standing;

  const LeaderboardTile({super.key, required this.standing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPromotionZone = standing.isPromoted;
    final isDemotionZone = standing.isDemoted;

    // Determine background color for current user
    Color backgroundColor;
    Color rankTextColor;
    Color nameTextColor;
    Color xpTextColor;

    if (isPromotionZone) {
      // Promoted: green text
      rankTextColor = AppColors.featherGreen;
      nameTextColor = AppColors.featherGreen;
      xpTextColor = AppColors.featherGreen;
      backgroundColor = standing.isCurrentUser
          ? AppColors.correctGreenLight
          : AppColors.snow;
    } else if (isDemotionZone) {
      // Demoted: red text
      rankTextColor = AppColors.cardinal;
      nameTextColor = AppColors.cardinal;
      xpTextColor = AppColors.cardinal;
      backgroundColor = standing.isCurrentUser
          ? AppColors.incorrectRedLight
          : AppColors.snow;
    } else {
      // Safe zone: blue text (or orange)
      rankTextColor = AppColors.macaw;
      nameTextColor = AppColors.macaw;
      xpTextColor = AppColors.macaw;
      backgroundColor = standing.isCurrentUser
          ? AppColors.macawLight
          : AppColors.snow;
    }

    Widget tile = Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: standing.isCurrentUser
            ? [
                BoxShadow(
                  color: rankTextColor.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8.r),
        onTap: () {
          if (!standing.isCurrentUser) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PublicProfilePage(
                  userId: standing.userId,
                  userName: standing.username ?? 'User',
                ),
              ),
            );
          }
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              // Rank badge
              _buildRankBadge(rankTextColor),
              SizedBox(width: 12.w),

              // Avatar
              AvatarDisplay(
                avatarString: standing.profilePictureUrl,
                frameId: standing.equippedFrameId,
                backgroundId: standing.equippedBackgroundId,
                radius: 20,
              ),
              SizedBox(width: 12.w),

              // Name and flag
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            standing.fullName ?? standing.username ?? 'User',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: nameTextColor,
                              fontSize: 18.sp,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (standing.isCurrentUser) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: isPromotionZone
                                  ? AppColors.correctGreenDark.withOpacity(0.3)
                                  : isDemotionZone
                                  ? AppColors.cardinal.withOpacity(0.3)
                                  : AppColors.wolf.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              'Bạn',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: nameTextColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text('🇺🇸', style: TextStyle(fontSize: 14.sp)),
                  ],
                ),
              ),

              // XP
              Text(
                '${standing.weeklyXp} KN',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.normal, // Not bold for XP
                  color: xpTextColor,
                  fontSize: 18.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (standing.isCurrentUser) {
      // Create a subtle shimmer sweep over the tile
      tile = Stack(
        children: [
          tile,
          Positioned.fill(
            child: Shimmer.fromColors(
              baseColor: Colors.transparent,
              highlightColor: Colors.white.withOpacity(0.4),
              period: const Duration(seconds: 3),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return tile;
  }

  Widget _buildRankBadge(Color rankTextColor) {
    Color bgColor;
    Widget child;

    if (standing.rank <= 3) {
      // Top 3 with emoji
      bgColor = standing.isCurrentUser
          ? Colors.transparent
          : _getRankColor(standing.rank);
      child = Text(
        _getRankEmoji(standing.rank),
        style: TextStyle(fontSize: 24.sp),
      );
    } else {
      // Regular rank number
      bgColor = standing.isCurrentUser
          ? Colors.transparent
          : AppColors.wolf.withOpacity(0.1);
      child = Text(
        '${standing.rank}',
        style: TextStyle(
          color: standing.isCurrentUser ? rankTextColor : AppColors.wolf,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return Container(
      width: 36.w,
      height: 36.w,
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      child: Center(child: child),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return AppColors.bee.withOpacity(0.2); // Gold
      case 2:
        return AppColors.wolf.withOpacity(0.2); // Silver
      case 3:
        return AppColors.fox.withOpacity(0.2); // Bronze
      default:
        return AppColors.macaw.withOpacity(0.1);
    }
  }

  String _getRankEmoji(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '';
    }
  }
}
