import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/profile/domain/entities/public_profile_entity.dart';
import 'package:vocabu_rex_mobile/profile/ui/blocs/public_profile_bloc.dart';
import 'package:vocabu_rex_mobile/profile/ui/blocs/profile_bloc.dart';
import 'package:vocabu_rex_mobile/profile/ui/widgets/weekly_xp_chart.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
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
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          title: const Text('Thông tin người dùng'),
          elevation: 0,
        ),
        body: BlocBuilder<PublicProfileBloc, PublicProfileState>(
          builder: (context, state) {
            if (state is PublicProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is PublicProfileError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64.sp, color: Colors.grey),
                    SizedBox(height: 16.h),
                    Text(
                      state.message,
                      style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                    ),
                  ],
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
    // Get current user's profile from ProfileBloc
    final profileBloc = context.read<ProfileBloc>();
    final currentUserProfile = profileBloc.state is ProfileLoaded
        ? (profileBloc.state as ProfileLoaded).profile
        : null;
    
    final myXpHistory = currentUserProfile?.xpHistory ?? [];
    final myTotalXp = myXpHistory.fold<int>(0, (sum, e) => sum + e.xp);
    
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
              ),
            ),
            child: Column(
              children: [
                SizedBox(height: 24.h),
                // Avatar
                CircleAvatar(
                  radius: 50.r,
                  backgroundImage: profile.avatarUrl.isNotEmpty
                      ? NetworkImage(profile.avatarUrl)
                      : null,
                  backgroundColor: Colors.white,
                  child: profile.avatarUrl.isEmpty
                      ? Icon(Icons.person, size: 50.sp, color: AppColors.primary)
                      : null,
                ),
                SizedBox(height: 16.h),
                // Username
                Text(
                  profile.username,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8.h),
                // Follow button
                _buildFollowButton(context, profile),
                SizedBox(height: 24.h),
              ],
            ),
          ),

          // Stats Section
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overview Stats
                _buildOverviewStats(profile),
                SizedBox(height: 24.h),

                // Weekly XP Chart
                Text(
                  'So sánh kinh nghiệm 7 ngày',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),
                WeeklyXPChart(
                  myName: userName,
                  theirName: profile.username,
                  myXpHistory: myXpHistory,
                  theirXpHistory: profile.xpHistory,
                  myTotalXp: myTotalXp,
                  theirTotalXp: profile.xpHistory.fold<int>(0, (s, e) => s + e.xp),
                ),
                SizedBox(height: 24.h),

                // Achievements
                _buildAchievementsSection(profile),
                SizedBox(height: 24.h),

                // Moderation Buttons
                _buildModerationButtons(context, profile),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowButton(BuildContext context, PublicProfileEntity profile) {
    return BlocBuilder<PublicProfileBloc, PublicProfileState>(
      builder: (context, state) {
        final isFollowing = state is PublicProfileLoaded 
            ? state.profile.isFollowedByMe 
            : profile.isFollowedByMe;

        return ElevatedButton.icon(
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
          icon: Icon(
            isFollowing ? Icons.person_remove : Icons.person_add,
            size: 20.sp,
          ),
          label: Text(
            isFollowing ? 'Hủy theo dõi' : 'Theo dõi',
            style: TextStyle(fontSize: 14.sp),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: isFollowing ? Colors.grey : AppColors.macaw,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.r),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOverviewStats(PublicProfileEntity profile) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Người theo dõi', profile.followerCount.toString()),
              _buildDivider(),
              _buildStatItem('Đang theo dõi', profile.followingCount.toString()),
              _buildDivider(),
              _buildStatItem('Tổng KN', profile.totalXp.toString()),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Chuỗi ngày', '${profile.streakDays} ngày'),
              _buildDivider(),
              _buildStatItem('Cấp độ', profile.currentLevel.toString()),
              _buildDivider(),
              _buildStatItem('Top 3', profile.top3Count.toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1.w,
      height: 40.h,
      color: Colors.grey[300],
    );
  }

  Widget _buildAchievementsSection(PublicProfileEntity profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thành tích',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildAchievementRow('Chuỗi ngày', '${profile.streakDays} ngày'),
              _buildAchievementRow('Top 3', profile.top3Count.toString()),
              _buildAchievementRow('Tham gia giải đấu', profile.isInTournament ? 'Có' : 'Không'),
              _buildAchievementRow('Điểm tiếng Anh', profile.englishScore.toString()),
              _buildAchievementRow('Ngày tham gia', profile.joinedDate),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14.sp, color: Colors.black87),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
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
          child: OutlinedButton.icon(
            onPressed: () => _showReportDialog(context),
            icon: Icon(Icons.flag, size: 20.sp, color: AppColors.cardinal),
            label: Text(
              'Báo cáo người dùng',
              style: TextStyle(fontSize: 14.sp, color: AppColors.cardinal),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.cardinal),
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        // Block button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showBlockDialog(context),
            icon: Icon(Icons.block, size: 20.sp),
            label: Text('Chặn người dùng', style: TextStyle(fontSize: 14.sp)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[700],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
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
