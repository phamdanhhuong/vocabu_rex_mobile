import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/profile/domain/entities/profile_entity.dart';
import 'package:vocabu_rex_mobile/constants/app_colors.dart';

class ProfileFollowing extends StatelessWidget {
  final ProfileEntity profile;
  const ProfileFollowing({Key? key, required this.profile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Đang theo dõi ${profile.followingCount}', style: const TextStyle(color: AppColors.primaryBlue)),
        Text('Người theo dõi ${profile.followerCount}', style: const TextStyle(color: AppColors.primaryBlue)),
      ],
    );
  }
}
