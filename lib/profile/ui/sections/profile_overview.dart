import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
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
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 2.0, // Làm cho thẻ rộng hơn
        children: [
          StatCard(
            icon: Icon(Icons.whatshot, color: AppColors.fox, size: 28.sp),
            value: '${profile?.streakDays ?? 0}',
            label: 'Ngày streak',
          ),
          StatCard(
            icon: Icon(Icons.flash_on, color: AppColors.bee, size: 28.sp),
            value: '${profile?.totalExp ?? 0} KN',
            label: 'Tổng KN',
          ),
          StatCard(
            icon: Icon(Icons.shield, color: AppColors.wolf, size: 28.sp),
            value: profile != null && profile!.isInTournament
                ? 'Đang tham gia'
                : 'Chưa tham gia',
            label: 'Giải đấu hiện tại',
          ),
          StatCard(
            icon: Image.asset(
              profile != null
                  ? 'assets/flags/${profile!.countryCode}.png'
                  : 'assets/flags/english.png',
              width: 28.w,
            ),
            value: '${profile?.top3Count ?? 0}',
            label: 'Top 3',
          ),
        ],
      ),
    );
  }
}
