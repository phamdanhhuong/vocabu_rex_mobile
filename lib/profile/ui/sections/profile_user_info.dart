import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/profile/domain/entities/profile_entity.dart';
import 'package:vocabu_rex_mobile/profile/ui/pages/avatar_builder_page.dart';
import 'package:vocabu_rex_mobile/profile/ui/widgets/avatar_display.dart';
import 'package:vocabu_rex_mobile/auth/data/services/auth_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/profile/ui/blocs/profile_bloc.dart';

/// Section hiển thị thông tin cá nhân của user
class ProfileUserInfo extends StatelessWidget {
  final ProfileEntity? profile;

  const ProfileUserInfo({super.key, required this.profile});

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
          GestureDetector(
            onTap: () async {
              final newUrl = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AvatarBuilderPage(
                    initialUrl: profile?.avatarUrl,
                  ),
                ),
              );
              
              if (newUrl != null && newUrl is String && newUrl != profile?.avatarUrl) {
                // Hiển thị loading (tùy chọn) hoặc snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đang cập nhật avatar...')),
                );
                
                try {
                  await AuthService().updateProfile(
                    profilePictureUrl: newUrl,
                  );
                  if (context.mounted) {
                    context.read<ProfileBloc>().add(GetProfileEvent());
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cập nhật thành công!'), backgroundColor: Colors.green),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              }
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                AvatarDisplay(
                  avatarString: profile?.avatarUrl,
                  radius: 40,
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
          ),
        ],
      ),
    );
  }
}
