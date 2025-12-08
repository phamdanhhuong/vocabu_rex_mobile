import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/profile/domain/entities/profile_entity.dart';
import 'package:vocabu_rex_mobile/profile/ui/widgets/stat_card.dart';

/// Section hiển thị tổng quan thống kê
class ProfileOverview extends StatelessWidget {
  final ProfileEntity? profile;

  const ProfileOverview({
    Key? key,
    required this.profile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
        childAspectRatio: 2.2, // Adjusted for better fit
        children: [
          StatCard(
            icon: Image.asset(
              'assets/icons/streak.png',
              width: 24.w,
              height: 24.w,
            ),
            value: '${profile?.streakDays ?? 0}',
            label: 'Ngày streak',
          ),
          StatCard(
            icon: Image.asset(
              'assets/icons/xp.png',
              width: 24.w,
              height: 24.w,
            ),
            value: '${profile?.totalExp ?? 0} KN',
            label: 'Tổng KN',
          ),
          StatCard(
            icon: Image.asset(
              'assets/icons/reward.png',
              width: 24.w,
              height: 24.w,
            ),
            value: profile?.currentLeagueTier != null 
                ? _formatLeagueTier(profile!.currentLeagueTier!)
                : (profile != null && profile!.isInTournament
                    ? 'Đang tham gia'
                    : 'Chưa tham gia'),
            label: 'Giải đấu hiện tại',
          ),
          StatCard(
            icon: Image.asset('assets/flags/english.png',
              width: 24.w,
              height: 24.w,
            ),
            value: '${profile?.skillPosition ?? 0}',
            label: 'Bài học hiện tại',
          ),
        ],
      ),
    );
  }

  String _formatLeagueTier(String tier) {
    final tierMap = {
      'BRONZE': 'Đồng',
      'SILVER': 'Bạc',
      'GOLD': 'Vàng',
      'DIAMOND': 'Kim cương',
      'OBSIDIAN': 'Hắc diện thạch',
    };
    return tierMap[tier] ?? tier;
  }
}
