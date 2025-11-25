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

    // Determine background color for current user
    Color backgroundColor;
    Color rankTextColor;
    Color nameTextColor;
    Color xpTextColor;
    
    if (standing.isCurrentUser) {
      if (isPromotionZone) {
        // Promoted: light green background, dark green text
        backgroundColor = AppColors.correctGreenLight; // Light green background
        rankTextColor = AppColors.featherGreen; // Dark green for rank
        nameTextColor = AppColors.featherGreen; // Dark green for name
        xpTextColor = AppColors.featherGreen; // Normal color for XP (not bold)
      } else if (isDemotionZone) {
        // Demoted: light red background, dark red text
        backgroundColor = AppColors.incorrectRedLight; // Light red background
        rankTextColor = AppColors.cardinal; // Dark red for rank
        nameTextColor = AppColors.cardinal; // Dark red for name
        xpTextColor = AppColors.cardinal; // Normal color for XP (not bold)
      } else {
        // Neutral: light gray background, dark gray text
        backgroundColor = AppColors.swan; // Light gray background
        rankTextColor = AppColors.wolf; // Dark gray for rank
        nameTextColor = AppColors.wolf; // Dark gray for name
        xpTextColor = AppColors.wolf; // Normal color for XP (not bold)
      }
    } else {
      backgroundColor = (isPromotionZone || isDemotionZone)
          ? Colors.white
          : AppColors.snow;
      rankTextColor = AppColors.eel;
      nameTextColor = AppColors.eel;
      xpTextColor = AppColors.eel;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: backgroundColor,
      ),
      child: Row(
        children: [
          // Rank badge
          _buildRankBadge(rankTextColor),
          SizedBox(width: 12.w),

          // Avatar
          CircleAvatar(
            radius: 20.r,
            backgroundColor: standing.isCurrentUser
                ? (isPromotionZone 
                    ? AppColors.correctGreenDark.withOpacity(0.3)
                    : isDemotionZone
                        ? AppColors.cardinal.withOpacity(0.3)
                        : AppColors.wolf.withOpacity(0.3))
                : AppColors.featherGreen.withOpacity(0.2),
            backgroundImage: standing.profilePictureUrl != null &&
                    standing.profilePictureUrl!.isNotEmpty
                ? NetworkImage(standing.profilePictureUrl!)
                : null,
            child: standing.profilePictureUrl == null ||
                    standing.profilePictureUrl!.isEmpty
                ? Icon(
                    Icons.person,
                    color: standing.isCurrentUser 
                        ? (isPromotionZone 
                            ? AppColors.correctGreenDark
                            : isDemotionZone
                                ? AppColors.cardinal
                                : AppColors.wolf)
                        : AppColors.featherGreen,
                    size: 20.sp,
                  )
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
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
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
              fontWeight: FontWeight.normal, // Not bold for XP
              color: xpTextColor,
              fontSize: 18.sp,
            ),
          ),
        ],
      ),
    );
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
