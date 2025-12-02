import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/profile/domain/entities/public_profile_entity.dart';
import 'package:vocabu_rex_mobile/profile/domain/entities/profile_entity.dart';
import 'package:vocabu_rex_mobile/profile/ui/blocs/public_profile_bloc.dart';
import 'package:vocabu_rex_mobile/profile/ui/blocs/profile_bloc.dart';
import 'package:vocabu_rex_mobile/profile/ui/widgets/weekly_xp_chart.dart';
import 'package:vocabu_rex_mobile/profile/ui/sections/profile_user_info.dart';
import 'package:vocabu_rex_mobile/profile/ui/sections/profile_overview.dart';
import 'package:vocabu_rex_mobile/profile/ui/sections/profile_achievements.dart';
import 'package:vocabu_rex_mobile/profile/ui/widgets/profile_section_header.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/profile_button.dart';
import 'package:vocabu_rex_mobile/friend/ui/widgets/friends_list_view.dart';
import 'package:vocabu_rex_mobile/core/injection.dart' as di;

class PublicProfilePage extends StatelessWidget {
  final String userId;
  final String userName; // Tên hiển thị của người dùng hiện tại

  const PublicProfilePage({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<PublicProfileBloc>()
        ..add(GetPublicProfileEvent(userId)),
      child: Scaffold(
        backgroundColor: AppColors.snow,
        appBar: AppBar(
          backgroundColor: AppColors.snow,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.bodyText),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Thông tin người dùng',
            style: TextStyle(
              color: AppColors.bodyText,
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<PublicProfileBloc, PublicProfileState>(
          builder: (context, state) {
            if (state is PublicProfileLoading) {
              return Center(child: CircularProgressIndicator());
            }

            if (state is PublicProfileError) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(32.w),
                  child: Text('Lỗi: ${state.message}'),
                ),
              );
            }

            if (state is PublicProfileLoaded) {
              return _buildProfileContent(context, state.profile);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, PublicProfileEntity profile) {
    // Convert PublicProfileEntity to ProfileEntity để tái sử dụng UI components
    final profileEntity = ProfileEntity(
      id: profile.id,
      username: profile.username,
      displayName: profile.displayName,
      avatarUrl: profile.avatarUrl,
      joinedDate: profile.joinedDate,
      countryCode: profile.countryCode,
      followingCount: profile.followingCount,
      followerCount: profile.followerCount,
      streakDays: profile.streakDays,
      totalExp: profile.totalXp,
      isInTournament: profile.isInTournament,
      top3Count: profile.top3Count,
      xpHistory: profile.xpHistory,
    );

    // Get current user's XP history for comparison chart
    final profileBloc = context.read<ProfileBloc>();
    final currentUserProfile = profileBloc.state is ProfileLoaded
        ? (profileBloc.state as ProfileLoaded).profile
        : null;
    
    final myXpHistory = currentUserProfile?.xpHistory ?? [];
    final myTotalXp = myXpHistory.fold<int>(0, (sum, e) => sum + e.xp);
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Thông tin cá nhân (tái sử dụng ProfileUserInfo)
          ProfileUserInfo(profile: profileEntity),

          // 2. Nút hành động (Theo dõi/Hủy theo dõi, Người theo dõi, Đang theo dõi)
          _buildActionButtons(context, profile),
          Divider(color: AppColors.swan, height: 1.h),

          // 3. Mục "Tổng quan" (tái sử dụng ProfileOverview)
          ProfileSectionHeader(title: 'Tổng quan'),
          ProfileOverview(profile: profileEntity),

          // 4. Biểu đồ so sánh XP 7 ngày
          ProfileSectionHeader(title: 'So sánh kinh nghiệm 7 ngày'),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.swan, width: 2),
              ),
              child: WeeklyXPChart(
                myName: userName,
                theirName: profile.username,
                myXpHistory: myXpHistory,
                theirXpHistory: profile.xpHistory,
                myTotalXp: myTotalXp,
                theirTotalXp: profile.xpHistory.fold<int>(0, (s, e) => s + e.xp),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // 5. Mục "Thành tích" (tái sử dụng ProfileAchievements)
          ProfileSectionHeader(title: 'Thành tích'),
          ProfileAchievements(),

          // 6. Nút Moderation (Báo cáo & Chặn)
          Padding(
            padding: EdgeInsets.all(16.w),
            child: _buildModerationButtons(context, profile),
          ),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, PublicProfileEntity profile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        children: [
          // Thống kê theo dõi
          Row(
            children: [
              // Đang theo dõi (clickable)
              Flexible(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          FriendsListView(
                            initialTabIndex: 0,
                            userId: userId, // Xem danh sách của người này
                          ),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                            .chain(CurveTween(curve: Curves.easeOut));
                        return SlideTransition(position: animation.drive(tween), child: child);
                      },
                      transitionDuration: const Duration(milliseconds: 320),
                    ));
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          'Đang theo dõi ',
                          style: TextStyle(
                            color: AppColors.macaw,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${profile.followingCount}',
                        style: TextStyle(
                          color: AppColors.macaw,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              // Người theo dõi (clickable)
              Flexible(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          FriendsListView(
                            initialTabIndex: 1,
                            userId: userId, // Xem danh sách của người này
                          ),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                            .chain(CurveTween(curve: Curves.easeOut));
                        return SlideTransition(position: animation.drive(tween), child: child);
                      },
                      transitionDuration: const Duration(milliseconds: 320),
                    ));
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${profile.followerCount}',
                        style: TextStyle(
                          color: AppColors.macaw,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Flexible(
                        child: Text(
                          'Người theo dõi',
                          style: TextStyle(
                            color: AppColors.macaw,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Nút bấm (Theo dõi/Hủy theo dõi + icon share)
          BlocBuilder<PublicProfileBloc, PublicProfileState>(
            builder: (context, state) {
              final isFollowing = state is PublicProfileLoaded 
                  ? state.profile.isFollowedByMe 
                  : profile.isFollowedByMe;

              return Row(
                children: [
                  Expanded(
                    child: ProfileButton(
                      icon: isFollowing ? Icons.person_remove : Icons.person_add,
                      label: isFollowing ? 'HỦY THEO DÕI' : 'THEO DÕI',
                      onPressed: () {
                        if (isFollowing) {
                          context.read<PublicProfileBloc>().add(
                            UnfollowPublicUserEvent(userId),
                          );
                        } else {
                          context.read<PublicProfileBloc>().add(
                            FollowPublicUserEvent(userId),
                          );
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  ProfileButton(
                    icon: Icons.ios_share_outlined,
                    onPressed: () {},
                    isIconOnly: true,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModerationButtons(BuildContext context, PublicProfileEntity profile) {
    return Column(
      children: [
        // Report button
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: () => _showReportDialog(context),
            icon: Icon(Icons.flag_outlined, size: 20.sp, color: AppColors.wolf),
            label: Text(
              'BÁO CÁO NGƯỜI DÙNG',
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.wolf,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 14.h),
            ),
          ),
        ),
        // Block button
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: () => _showBlockDialog(context),
            icon: Icon(Icons.block_outlined, size: 20.sp, color: AppColors.wolf),
            label: Text(
              'CHẶN NGƯỜI DÙNG',
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.wolf,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 14.h),
            ),
          ),
        ),
      ],
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        String? selectedReason;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Báo cáo người dùng'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Chọn lý do báo cáo:'),
                  SizedBox(height: 16.h),
                  ..._reportReasons.map((reason) {
                    return RadioListTile<String>(
                      title: Text(reason['label']!),
                      value: reason['value']!,
                      groupValue: selectedReason,
                      onChanged: (value) {
                        setState(() => selectedReason = value);
                      },
                      contentPadding: EdgeInsets.zero,
                    );
                  }),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: selectedReason == null
                      ? null
                      : () {
                          context.read<PublicProfileBloc>().add(
                            ReportPublicUserEvent(
                              userId: userId,
                              reason: selectedReason!,
                            ),
                          );
                          Navigator.pop(dialogContext);
                          _showSuccessSnackBar(context, 'Đã gửi báo cáo');
                        },
                  child: const Text('Gửi báo cáo'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showBlockDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Chặn người dùng'),
          content: const Text(
            'Bạn có chắc muốn chặn người dùng này? '
            'Họ sẽ không thể tương tác với bạn nữa.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<PublicProfileBloc>().add(
                  BlockPublicUserEvent(userId),
                );
                Navigator.pop(dialogContext);
                Navigator.pop(context); // Return to previous screen
                _showSuccessSnackBar(context, 'Đã chặn người dùng');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cardinal,
              ),
              child: const Text('Chặn'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static final List<Map<String, String>> _reportReasons = [
    {'value': 'SPAM', 'label': 'Spam'},
    {'value': 'HARASSMENT', 'label': 'Quấy rối'},
    {'value': 'INAPPROPRIATE_CONTENT', 'label': 'Nội dung không phù hợp'},
    {'value': 'HATE_SPEECH', 'label': 'Ngôn từ thù ghét'},
    {'value': 'IMPERSONATION', 'label': 'Mạo danh'},
    {'value': 'OTHER', 'label': 'Khác'},
  ];
}
