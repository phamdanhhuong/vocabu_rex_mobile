import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/achievement/ui/widgets/all_achievements_view.dart';
import 'package:vocabu_rex_mobile/profile/ui/blocs/profile_bloc.dart';
import 'package:vocabu_rex_mobile/profile/domain/entities/profile_entity.dart';
import 'package:vocabu_rex_mobile/profile/ui/sections/profile_app_bar.dart';
import 'package:vocabu_rex_mobile/profile/ui/sections/profile_user_info.dart';
import 'package:vocabu_rex_mobile/profile/ui/sections/profile_action_buttons.dart';
import 'package:vocabu_rex_mobile/profile/ui/sections/profile_overview.dart';
import 'package:vocabu_rex_mobile/profile/ui/sections/profile_friend_streak.dart';
import 'package:vocabu_rex_mobile/profile/ui/sections/profile_achievements.dart';
import 'package:vocabu_rex_mobile/profile/ui/widgets/profile_section_header.dart';
import 'package:vocabu_rex_mobile/home/ui/widgets/dot_loading_indicator.dart';

/// Giao diện màn hình "Hồ sơ" (Profile).
class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // Request profile data when the page is shown
    // If the ProfileBloc is not provided above, this will throw; ensure the bloc is
    // provided in the widget tree that opens ProfilePage (e.g., via MultiBlocProvider).
    try {
      context.read<ProfileBloc>().add(GetProfileEvent());
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.snow,
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
            if (state is ProfileLoading) {
              return Padding(
                padding: EdgeInsets.all(32.w),
                child: const Center(child: DotLoadingIndicator(color: AppColors.macaw, size: 16)),
              );
            }

            if (state is ProfileError) {
              return Padding(
                padding: EdgeInsets.all(32.w),
                child: Center(child: Text('Error: ${state.message}')),
              );
            }

            final ProfileEntity? profile = state is ProfileLoaded ? state.profile : null;

            return LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = MediaQuery.of(context).size.width;
                final isWide = kIsWeb && screenWidth >= 768;

                if (isWide) {
                  // Màn hình rộng (Web): chia 2 cột
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ProfileAppBar(),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Cột trái: Thông tin cá nhân
                              Expanded(
                                flex: 4,
                                child: SingleChildScrollView(
                                  padding: EdgeInsets.symmetric(vertical: 16.h),
                                  child: Column(
                                    children: [
                                      ProfileUserInfo(profile: profile),
                                      ProfileActionButtons(profile: profile),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 32.w),
                              // Cột phải: Thống kê và Thành tích
                              Expanded(
                                flex: 6,
                                child: SingleChildScrollView(
                                  padding: EdgeInsets.symmetric(vertical: 16.h),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ProfileSectionHeader(title: 'Tổng quan'),
                                      ProfileOverview(profile: profile),
                                      const ProfileFriendStreak(),
                                      ProfileSectionHeader(
                                        title: 'Thành tích',
                                        actionText: 'XEM TẤT CẢ',
                                        onActionTap: () => _navigateToAchievements(context),
                                      ),
                                      const ProfileAchievements(),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }

                // Màn hình hẹp (Mobile): 1 cột duy nhất
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. App Bar (Hồ sơ + Cài đặt)
                    const ProfileAppBar(),

                    // 2. Thông tin cá nhân
                    ProfileUserInfo(profile: profile),

                    // 3. Nút hành động
                    ProfileActionButtons(profile: profile),
                    Divider(color: AppColors.swan, height: 1.h),

                    // 4. Mục "Tổng quan"
                    ProfileSectionHeader(
                      title: 'Tổng quan',
                    ),
                    ProfileOverview(profile: profile),

                    // 5. Mục "Streak bạn bè"
                    const ProfileFriendStreak(),

                    // 6. Mục "Thành tích"
                    ProfileSectionHeader(
                      title: 'Thành tích',
                      actionText: 'XEM TẤT CẢ',
                      onActionTap: () => _navigateToAchievements(context),
                    ),
                    const ProfileAchievements(),
                  ],
                ));
              },
            );
          },
        ),
    );
  }

  void _navigateToAchievements(BuildContext context) {
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const AllAchievementsView(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOut));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 320),
    ));
  }
}
