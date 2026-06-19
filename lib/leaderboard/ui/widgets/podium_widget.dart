import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:vocabu_rex_mobile/leaderboard/domain/entities/leaderboard_standing_entity.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/profile/ui/widgets/avatar_display.dart';
import 'package:vocabu_rex_mobile/profile/ui/pages/public_profile_page.dart';

class PodiumWidget extends StatelessWidget {
  final List<LeaderboardStandingEntity> top3;

  const PodiumWidget({super.key, required this.top3});

  @override
  Widget build(BuildContext context) {
    if (top3.isEmpty) return const SizedBox.shrink();

    // Make sure we sort them by rank just in case
    final sorted = List<LeaderboardStandingEntity>.from(top3)..sort((a, b) => a.rank.compareTo(b.rank));
    
    final first = sorted.isNotEmpty ? sorted[0] : null;
    final second = sorted.length > 1 ? sorted[1] : null;
    final third = sorted.length > 2 ? sorted[2] : null;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Rank 2 (Left)
          if (second != null)
            Expanded(
              child: BounceInUp(
                delay: const Duration(milliseconds: 200),
                child: _buildPodiumColumn(context, second, 2, 120.h, AppColors.wolf),
              ),
            )
          else
            const Spacer(),
          
          // Rank 1 (Center)
          if (first != null)
            Expanded(
              child: BounceInUp(
                child: _buildPodiumColumn(context, first, 1, 160.h, AppColors.bee, isCenter: true),
              ),
            )
          else
            const Spacer(),

          // Rank 3 (Right)
          if (third != null)
            Expanded(
              child: BounceInUp(
                delay: const Duration(milliseconds: 400),
                child: _buildPodiumColumn(context, third, 3, 90.h, AppColors.fox),
              ),
            )
          else
            const Spacer(),
        ],
      ),
    );
  }

  Widget _buildPodiumColumn(BuildContext context, LeaderboardStandingEntity user, int rank, double height, Color color, {bool isCenter = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Avatar + Crown
        GestureDetector(
          onTap: () {
            if (!user.isCurrentUser) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PublicProfilePage(
                    userId: user.userId,
                    userName: user.username ?? 'User',
                  ),
                ),
              );
            }
          },
          child: Builder(
            builder: (context) {
              Widget avatarContainer = Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: isCenter ? 4 : 2),
                  boxShadow: isCenter ? [
                    BoxShadow(
                      color: color.withOpacity(0.5),
                      blurRadius: 15,
                      spreadRadius: 5,
                    )
                  ] : null,
                ),
                child: ClipOval(
                  child: AvatarDisplay(
                    avatarString: user.profilePictureUrl,
                    radius: isCenter ? 40.w : 32.w,
                  ),
                ),
              );

              return Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  avatarContainer,
                  if (isCenter)
                    Positioned(
                      top: -24.h,
                      child: Pulse(
                        infinite: true,
                        duration: const Duration(seconds: 3),
                        child: Text('👑', style: TextStyle(fontSize: 36.sp)),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        SizedBox(height: 8.h),
        // Name
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                user.fullName ?? user.username ?? 'User',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isCenter ? 16.sp : 14.sp,
                  color: AppColors.eel,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (user.isCurrentUser) ...[
              SizedBox(width: 4.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppColors.featherGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4.r),
                  border: Border.all(color: AppColors.featherGreen),
                ),
                child: Text(
                  'Bạn',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.featherGreen,
                  ),
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 4.h),
        // XP
        Text(
          '${user.weeklyXp} KN',
          style: TextStyle(
            fontSize: 12.sp,
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 8.h),
        // Podium Bar
        Container(
          height: height,
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8.r),
              topRight: Radius.circular(8.r),
            ),
            border: Border.all(color: color, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 8.h),
              Text(
                '$rank',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
