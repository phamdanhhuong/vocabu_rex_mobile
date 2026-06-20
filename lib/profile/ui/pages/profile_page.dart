import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/achievement/ui/widgets/all_achievements_view.dart';
import 'package:vocabu_rex_mobile/profile/ui/blocs/profile_bloc.dart';
import 'package:vocabu_rex_mobile/profile/domain/entities/profile_entity.dart';
import 'package:vocabu_rex_mobile/profile/ui/sections/profile_user_info.dart';
import 'package:vocabu_rex_mobile/profile/ui/sections/profile_action_buttons.dart';
import 'package:vocabu_rex_mobile/profile/ui/sections/profile_overview.dart';
import 'package:vocabu_rex_mobile/profile/ui/sections/profile_battle_summary.dart';
import 'package:vocabu_rex_mobile/battle/ui/pages/battle_history_page.dart';
import 'package:vocabu_rex_mobile/profile/ui/sections/profile_achievements.dart';
import 'package:vocabu_rex_mobile/profile/ui/widgets/profile_section_header.dart';
import 'package:vocabu_rex_mobile/home/ui/widgets/smooth_loading_wrapper.dart';
import 'package:vocabu_rex_mobile/profile/ui/widgets/profile_loading_skeleton.dart';
import 'package:animate_do/animate_do.dart';

/// Giao diện màn hình "Hồ sơ" (Profile).
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

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
          final isLoading = state is ProfileLoading ||
              (state is! ProfileLoaded && state is! ProfileError);

          if (state is ProfileError) {
            return Padding(
              padding: EdgeInsets.all(32.w),
              child: Center(child: Text('Error: ${state.message}')),
            );
          }

          final ProfileEntity? profile = state is ProfileLoaded
              ? state.profile
              : null;

          Widget contentWidget = LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = MediaQuery.of(context).size.width;
              final isWide = kIsWeb && screenWidth >= 768;

              if (isWide) {
                // Màn hình rộng (Web): chia 2 cột
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 0,
                        ),
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
                                    FadeInDown(
                                      duration: const Duration(milliseconds: 600),
                                      child: ProfileUserInfo(profile: profile),
                                    ),
                                    FadeInUp(
                                      delay: const Duration(milliseconds: 100),
                                      duration: const Duration(milliseconds: 500),
                                      child: ProfileActionButtons(profile: profile),
                                    ),
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
                                    FadeInLeft(
                                      delay: const Duration(milliseconds: 200),
                                      duration: const Duration(milliseconds: 500),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          ProfileSectionHeader(title: 'Tổng quan'),
                                          ProfileOverview(profile: profile),
                                        ],
                                      ),
                                    ),
                                    FadeInUp(
                                      delay: const Duration(milliseconds: 300),
                                      duration: const Duration(milliseconds: 500),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          ProfileSectionHeader(
                                            title: 'Lịch sử đấu',
                                            actionText: 'XEM TẤT CẢ',
                                            onActionTap: () => Navigator.push(
                                              context,
                                              PageRouteBuilder(
                                                pageBuilder: (context, animation, secondaryAnimation) => const BattleHistoryPage(),
                                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                                  final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeOut));
                                                  return SlideTransition(position: animation.drive(tween), child: child);
                                                },
                                                transitionDuration: const Duration(milliseconds: 320),
                                              ),
                                            ),
                                          ),
                                          const ProfileBattleSummary(),
                                        ],
                                      ),
                                    ),
                                    FadeInUp(
                                      delay: const Duration(milliseconds: 400),
                                      duration: const Duration(milliseconds: 500),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          ProfileSectionHeader(
                                            title: 'Thành tích',
                                            actionText: 'XEM TẤT CẢ',
                                            onActionTap: () =>
                                                _navigateToAchievements(context),
                                          ),
                                          const ProfileAchievements(),
                                        ],
                                      ),
                                    ),
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

              // Màn hình hẹp (Mobile): 1 cột duy nhất dùng ListView.builder (Lazy loading)
              final sections = [
                // 1. Thông tin cá nhân
                FadeInDown(
                  duration: const Duration(milliseconds: 600),
                  child: ProfileUserInfo(profile: profile),
                ),
                // 2. Nút hành động
                FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  child: ProfileActionButtons(profile: profile),
                ),
                // 3. Đường kẻ ngang
                Divider(color: AppColors.swan, height: 1.h),
                // 4. Mục "Tổng quan"
                FadeInLeft(
                  duration: const Duration(milliseconds: 500),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProfileSectionHeader(title: 'Tổng quan'),
                      ProfileOverview(profile: profile),
                    ],
                  ),
                ),
                // 5. Mục "Lịch sử đấu"
                FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProfileSectionHeader(
                        title: 'Lịch sử đấu',
                        actionText: 'XEM TẤT CẢ',
                        onActionTap: () => Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => const BattleHistoryPage(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeOut));
                              return SlideTransition(position: animation.drive(tween), child: child);
                            },
                            transitionDuration: const Duration(milliseconds: 320),
                          ),
                        ),
                      ),
                      const ProfileBattleSummary(),
                    ],
                  ),
                ),
                // 6. Mục "Thành tích"
                FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProfileSectionHeader(
                        title: 'Thành tích',
                        actionText: 'XEM TẤT CẢ',
                        onActionTap: () => _navigateToAchievements(context),
                      ),
                      const ProfileAchievements(),
                    ],
                  ),
                ),
              ];

              return ListView.builder(
                cacheExtent: 100, // Đảm bảo chỉ build khi chuẩn bị xuất hiện
                itemCount: sections.length,
                itemBuilder: (context, index) {
                  return sections[index];
                },
              );
            },
          );

          return SmoothLoadingWrapper(
            isLoading: isLoading,
            loadingWidget: const ProfileLoadingSkeleton(),
            contentWidget: contentWidget,
          );
        },
      ),
    );
  }

  void _navigateToAchievements(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ZoomIn(
              duration: const Duration(milliseconds: 500),
              child: const AllAchievementsView(),
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }
}
