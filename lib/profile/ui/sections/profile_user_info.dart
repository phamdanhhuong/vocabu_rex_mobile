import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/profile/domain/entities/profile_entity.dart';
import 'package:vocabu_rex_mobile/profile/ui/pages/avatar_builder_page.dart';
import 'package:vocabu_rex_mobile/profile/ui/widgets/avatar_display.dart';
import 'package:vocabu_rex_mobile/auth/data/services/auth_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/profile/ui/blocs/profile_bloc.dart';
import 'package:vocabu_rex_mobile/shop/ui/blocs/shop_bloc.dart';
import 'package:vocabu_rex_mobile/profile/ui/sections/profile_app_bar.dart';

/// Section hiển thị thông tin cá nhân của user
class ProfileUserInfo extends StatelessWidget {
  final ProfileEntity? profile;
  final bool isPublic;

  const ProfileUserInfo({super.key, required this.profile, this.isPublic = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BlocBuilder<ShopBloc, ShopState>(
          builder: (context, shopState) {
            String? resolvedBgUrl;
            
            if (profile != null && profile!.equippedBackgroundId != null) {
              try {
                resolvedBgUrl = shopState.items
                    .firstWhere((e) => e.id == profile!.equippedBackgroundId)
                    .imageUrl;
              } catch (_) {}
            }

            return Stack(
              clipBehavior: Clip.none,
              children: [
                // Ảnh bìa
                Container(
                  height: 180.h,
                  decoration: BoxDecoration(
                    gradient: resolvedBgUrl == null
                        ? const LinearGradient(
                            colors: [AppColors.macaw, AppColors.beetle],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    image: resolvedBgUrl != null
                        ? DecorationImage(
                            image: NetworkImage(resolvedBgUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Stack(
                      children: [
                        Positioned(
                          right: -20,
                          top: -20,
                          child: Opacity(
                            opacity: 0.1,
                            child: Icon(Icons.star, size: 150.sp, color: AppColors.snow),
                          ),
                        ),
                        if (!isPublic)
                          const Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: ProfileAppBar(isDark: true),
                          ),
                      ],
                    ),
                  ),
                ),
                // Avatar đè lên biên giới
            Positioned(
              bottom: -48.h,
              left: 24.w,
              child: GestureDetector(
                onTap: isPublic ? null : () async {
                  final newUrl = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AvatarBuilderPage(
                        initialUrl: profile?.avatarUrl,
                      ),
                    ),
                  );
                  
                  if (newUrl != null && newUrl is String && newUrl != profile?.avatarUrl) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đang cập nhật avatar...')),
                    );
                    
                    try {
                      await AuthService().updateProfile(profilePictureUrl: newUrl);
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
                  (() {
                    final avatarWidget = AvatarDisplay(
                      avatarString: profile?.avatarUrl,
                      radius: 56, // Bigger avatar
                      frameId: profile?.equippedFrameId,
                      backgroundId: profile?.equippedBackgroundId,
                    );

                    return avatarWidget;
                  })(),
                  if (!isPublic)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: const BoxDecoration(
                          color: AppColors.macaw,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.edit, color: AppColors.snow, size: 16.sp),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      );
    }),
        SizedBox(height: 56.h), // Khoảng trống cho Avatar
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile?.displayName ?? 'Người dùng',
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: AppColors.bodyText,
                  fontWeight: FontWeight.bold,
                  fontSize: 28.sp,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                profile?.username ?? '',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.hare,
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.calendar_month, size: 16.sp, color: AppColors.wolf),
                  SizedBox(width: 4.w),
                  Text(
                    profile != null ? 'Đã tham gia ${profile!.joinedDate}' : '',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.wolf,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Image.asset('assets/flags/english.png', width: 32.w),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }
}
