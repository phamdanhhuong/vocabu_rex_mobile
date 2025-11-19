import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/leaderboard/domain/entities/leaderboard_standing_entity.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

class LeaderboardTile extends StatelessWidget {
  final LeaderboardStandingEntity standing;

  const LeaderboardTile({
    Key? key,
    required this.standing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPromotionZone = standing.isPromoted;
    final isDemotionZone = standing.isDemoted;

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: standing.isCurrentUser
            ? AppColors.swan
            : (isPromotionZone || isDemotionZone)
                ? Colors.white
                : AppColors.snow,
        border: standing.isCurrentUser
            ? Border.all(color: AppColors.macaw, width: 2.w)
            : null,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          // Rank badge
          _buildRankBadge(),
          SizedBox(width: 12.w),

          // Avatar
          CircleAvatar(
            radius: 20.r,
            backgroundColor: AppColors.featherGreen.withOpacity(0.2),
            backgroundImage: standing.profilePictureUrl != null &&
                    standing.profilePictureUrl!.isNotEmpty
                ? NetworkImage(standing.profilePictureUrl!)
                : null,
            child: standing.profilePictureUrl == null ||
                    standing.profilePictureUrl!.isEmpty
                ? Icon(Icons.person, color: AppColors.featherGreen, size: 20.sp)
                : null,
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
                          color: AppColors.eel,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (standing.isCurrentUser) ...[
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: AppColors.macaw,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          'Bạn',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10.sp,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  '🇺🇸',
                  style: TextStyle(fontSize: 14.sp),
                ),
              ],
            ),
          ),

          // XP
          Text(
            '${standing.weeklyXp} KN',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.eel,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankBadge() {
    Color bgColor;
    Widget child;

    if (standing.rank <= 3) {
      // Top 3 with emoji
      bgColor = _getRankColor(standing.rank);
      child = Text(
        _getRankEmoji(standing.rank),
        style: TextStyle(fontSize: 24.sp),
      );
    } else {
      // Regular rank number
      bgColor = AppColors.wolf.withOpacity(0.1);
      child = Text(
        '${standing.rank}',
        style: TextStyle(
          color: AppColors.wolf,
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return Container(
      width: 36.w,
      height: 36.w,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
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
