import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/profile/domain/entities/profile_entity.dart';
import 'package:vocabu_rex_mobile/constants/app_colors.dart';

class ProfileOverview extends StatelessWidget {
  final ProfileEntity profile;
  const ProfileOverview({Key? key, required this.profile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tổng quan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textWhite)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _OverviewItem(icon: Icons.local_fire_department, label: '${profile.streakDays} Ngày streak'),
            _OverviewItem(icon: Icons.flash_on, label: '${profile.totalExp} KN'),
            _OverviewItem(icon: Icons.emoji_events, label: profile.isInTournament ? 'Đang tham gia' : 'Chưa tham gia'),
            _OverviewItem(icon: Icons.military_tech, label: '${profile.top3Count} Top 3'),
          ],
        ),
      ],
    );
  }
}

class _OverviewItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _OverviewItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.overlayBlack26,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.characterOrange, size: 28),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppColors.textWhite)),
        ],
      ),
    );
  }
}
