import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/profile/domain/entities/profile_entity.dart';
import 'package:vocabu_rex_mobile/profile/ui/widgets/stat_card.dart';

/// Section hiển thị tổng quan thống kê
class ProfileOverview extends StatelessWidget {
  final ProfileEntity? profile;

  const ProfileOverview({super.key, required this.profile});

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
          BounceInUp(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 100),
            child: StatCard(
              themeColor: AppColors.cardinal,
              icon: Image.asset(
                'assets/icons/streak.png',
                width: 24.w,
                height: 24.w,
              ),
              value: '${profile?.streakDays ?? 0}',
              label: 'Ngày streak',
            ),
          ),
          BounceInUp(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 200),
            child: StatCard(
              themeColor: AppColors.macaw,
              icon: Image.asset('assets/icons/xp.png', width: 24.w, height: 24.w),
              value: '${profile?.totalExp ?? 0} KN',
              label: 'Tổng KN',
            ),
          ),
          BounceInUp(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 300),
            child: StatCard(
              themeColor: AppColors.bee,
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
          ),
          BounceInUp(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 400),
            child: StatCard(
              themeColor: AppColors.featherGreen,
              icon: Image.asset(
                'assets/flags/english.png',
                width: 24.w,
                height: 24.w,
              ),
              value: '${profile?.skillPosition ?? 0}',
              label: 'Bài học hiện tại',
            ),
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
      'SAPPHIRE': 'Ngọc bích',
      'RUBY': 'Hồng ngọc',
      'EMERALD': 'Ngọc lục bảo',
      'AMETHYST': 'Thạch anh tím',
      'PEARL': 'Ngọc trai',
      'OBSIDIAN': 'Hắc diện thạch',
      'DIAMOND': 'Kim cương',
    };
    return tierMap[tier] ?? tier;
  }
}
