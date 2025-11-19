import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

class LeagueHeaderWidget extends StatelessWidget {
  final String tier;
  final int daysRemaining;

  const LeagueHeaderWidget({
    Key? key,
    required this.tier,
    this.daysRemaining = 6,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.swan, width: 2.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildTierIcon(),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Giải đấu ${_getTierDisplayName()}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.eel,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Top 10 sẽ được thăng hạng lên giải đấu cao hơn',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.wolf,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.fox.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.timer_outlined, color: AppColors.fox, size: 16.sp),
                    SizedBox(width: 4.w),
                    Text(
                      '$daysRemaining NGÀY',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.fox,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Trophy icons row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTrophyIcon('🏆', opacity: 0.3),
              _buildTrophyIcon('🏆', opacity: 0.3),
              _buildTrophyIcon('🏆', opacity: 1.0, isHighlighted: true),
              _buildTrophyIcon('🔒', opacity: 0.3),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTierIcon() {
    Color color;
    switch (tier) {
      case 'BRONZE':
        color = AppColors.fox;
        break;
      case 'SILVER':
        color = AppColors.wolf;
        break;
      case 'GOLD':
        color = AppColors.bee;
        break;
      case 'DIAMOND':
        color = AppColors.macaw;
        break;
      case 'OBSIDIAN':
        color = AppColors.eel;
        break;
      default:
        color = AppColors.fox;
    }

    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.emoji_events, color: color, size: 28.sp),
    );
  }

  Widget _buildTrophyIcon(String emoji, {double opacity = 1.0, bool isHighlighted = false}) {
    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        color: isHighlighted ? AppColors.bee.withOpacity(0.2) : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Opacity(
          opacity: opacity,
          child: Text(
            emoji,
            style: TextStyle(fontSize: 32.sp),
          ),
        ),
      ),
    );
  }

  String _getTierDisplayName() {
    switch (tier) {
      case 'BRONZE':
        return 'Đồng';
      case 'SILVER':
        return 'Bạc';
      case 'GOLD':
        return 'Vàng';
      case 'DIAMOND':
        return 'Kim cương';
      case 'OBSIDIAN':
        return 'Obsidian';
      default:
        return tier;
    }
  }
}
