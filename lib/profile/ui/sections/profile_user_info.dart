import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/profile/domain/entities/profile_entity.dart';

/// Section hiển thị thông tin cá nhân của user
class ProfileUserInfo extends StatelessWidget {
  final ProfileEntity? profile;

  const ProfileUserInfo({
    Key? key,
    required this.profile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          // Cột Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile?.displayName ?? 'Người dùng',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: AppColors.bodyText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  profile?.username ?? '',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.wolf,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  profile != null ? 'Đã tham gia ${profile!.joinedDate}' : '',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.wolf,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.h),
                Image.asset('assets/flags/english.png', width: 96.w),
                // Placeholder cho lá cờ
                // Image.asset(profile != null ? 'assets/flags/${profile.countryCode}.png' : 'assets/flags/english.png', width: 96.w),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          // Avatar
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 40.r,
                backgroundColor: AppColors.cardinal.withOpacity(0.2),
                foregroundImage: profile != null && profile!.avatarUrl.isNotEmpty
                    ? NetworkImage(profile!.avatarUrl) as ImageProvider
                    : null,
                child: profile == null || profile!.avatarUrl.isEmpty
                    ? Icon(Icons.person, size: 50.sp, color: AppColors.cardinal)
                    : null,
              ),
              Positioned(
                top: -4.h,
                right: -4.w,
                child: CircleAvatar(
                  radius: 12.r,
                  backgroundColor: AppColors.macaw,
                  child: Icon(Icons.edit, color: AppColors.snow, size: 14.sp),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
