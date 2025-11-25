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
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.snow,
        border: Border(
          bottom: BorderSide(color: AppColors.swan, width: 2.w),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column: Title and description
                Flexible(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Giải đấu ${_getTierDisplayName()}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.eel,
                          fontSize: 24.sp,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Top 10 sẽ được thăng hạng lên giải đấu cao hơn',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.wolf,
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                // Right column: Days remaining
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.timer_outlined, color: AppColors.fox, size: 16.sp),
                      SizedBox(width: 4.w),
                      Text(
                        '$daysRemaining NGÀY',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.fox,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          // Trophy icons row with wave pattern - horizontally scrollable
          SizedBox(
            height: 80.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 10, // Show more tiers for scrolling
              itemBuilder: (context, index) {
                double verticalOffset = index % 2 == 0 ? -8.h : 8.h;
                bool isLocked = index > _getCurrentTierIndex() + 2;
                
                return _buildTrophyIcon(
                  index,
                  verticalOffset: verticalOffset,
                  isLocked: isLocked,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrophyIcon(int position, {bool isLocked = false, double verticalOffset = 0}) {
    String tierImagePath = _getTierImagePath(position);
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Transform.translate(
        offset: Offset(0, verticalOffset),
        child: Container(
          width: 56.w,
          height: 56.w,
          child: Center(
            child: isLocked
                ? Icon(Icons.lock, size: 32.sp, color: AppColors.wolf)
                : Image.asset(
                    tierImagePath,
                    width: 48.w,
                    height: 48.w,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback to emoji if image not found
                      return Text('🏆', style: TextStyle(fontSize: 32.sp));
                    },
                  ),
          ),
        ),
      ),
    );
  }

  String _getTierImagePath(int position) {
    // Map position to tier based on current tier
    List<String> tiers = ['bronze', 'silver', 'gold', 'diamond', 'obsidian'];
    int currentIndex = tiers.indexOf(tier.toLowerCase());
    
    if (currentIndex == -1) currentIndex = 0;
    
    // Position 1: previous tier, Position 2: previous tier, Position 3: current tier, Position 4: next tier
    int targetIndex;
    if (position == 1 || position == 2) {
      targetIndex = currentIndex > 0 ? currentIndex - 1 : 0;
    } else if (position == 3) {
      targetIndex = currentIndex;
    } else {
      targetIndex = currentIndex < tiers.length - 1 ? currentIndex + 1 : currentIndex;
    }
    
    return 'assets/icons/tier_${tiers[targetIndex]}.png';
  }

  int _getCurrentTierIndex() {
    List<String> tiers = ['bronze', 'silver', 'gold', 'diamond', 'obsidian'];
    int index = tiers.indexOf(tier.toLowerCase());
    return index == -1 ? 0 : index;
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
