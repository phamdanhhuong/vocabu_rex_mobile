import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/profile/domain/entities/profile_entity.dart';
import 'package:vocabu_rex_mobile/constants/app_colors.dart';

class ProfileHeader extends StatelessWidget {
  final ProfileEntity profile;
  const ProfileHeader({Key? key, required this.profile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: NetworkImage(profile.avatarUrl),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(profile.displayName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textWhite)),
              Text(profile.username, style: const TextStyle(fontSize: 16, color: AppColors.textWhite70)),
              Text('Đã tham gia ${profile.joinedDate}', style: const TextStyle(fontSize: 14, color: AppColors.textWhite70)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Image.asset('assets/flags/${profile.countryCode}.png', width: 32, height: 20),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.edit, color: AppColors.textWhite),
          onPressed: () {},
        ),
      ],
    );
  }
}
