import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/achievement/ui/widgets/all_achievements_view.dart';
import 'package:vocabu_rex_mobile/friend/ui/widgets/find_friends_view.dart';
import 'package:vocabu_rex_mobile/friend/ui/widgets/friends_list_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/profile/ui/blocs/profile_bloc.dart';
import 'package:vocabu_rex_mobile/profile/domain/entities/profile_entity.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/app_button.dart';

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
    final theme = Theme.of(context);
    
    return Container(
      color: AppColors.snow,
      child: SingleChildScrollView(
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return Padding(
                padding: EdgeInsets.all(32.w),
                child: const Center(child: CircularProgressIndicator()),
              );
            }

            if (state is ProfileError) {
              return Padding(
                padding: EdgeInsets.all(32.w),
                child: Center(child: Text('Error: ${state.message}')),
              );
            }

            final ProfileEntity? profile = state is ProfileLoaded ? state.profile : null;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. App Bar (Hồ sơ + Cài đặt)
                _buildAppBar(context, theme),

                // 2. Thông tin cá nhân
                _buildUserInfo(context, profile, theme),

                // Divider + Action buttons
                Divider(color: AppColors.swan, height: 1.h),
                _buildActionButtons(context, profile, theme),
                Divider(color: AppColors.swan, height: 1.h),

                // 4. Mục "Tổng quan"
                _buildSectionHeader(context, theme, title: 'Tổng quan'),
                _buildOverviewGrid(context, profile, theme),

                // 5. Mục "Streak bạn bè"
                _buildFriendStreak(context, theme),

                // 6. Mục "Thành tích"
                _buildSectionHeader(
                  context,
                  theme,
                  title: 'Thành tích',
                  actionText: 'XEM TẤT CẢ',
                  onActionTap: () {
                    Navigator.of(context).push(PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => const AllAchievementsView(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeOut));
                        return SlideTransition(position: animation.drive(tween), child: child);
                      },
                      transitionDuration: const Duration(milliseconds: 320),
                    ));
                  },
                ),
                _buildAchievements(context, theme),
              ],
            );
          },
        ),
      ),
    );
  }
  // --- 1. APP BAR ---
  Widget _buildAppBar(BuildContext context, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h)
          .copyWith(top: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(width: 40.w), // Placeholder cho cân bằng
          Text(
            'Hồ sơ',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: AppColors.bodyText,
            ),
          ),
          IconButton(
            icon: Icon(Icons.settings, color: AppColors.macaw, size: 28.sp),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // --- 2. THÔNG TIN CÁ NHÂN ---
  Widget _buildUserInfo(BuildContext context, ProfileEntity? profile, ThemeData theme) {
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
                  profile != null ? 'Đã tham gia ${profile.joinedDate}' : '',
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
          // Avatar (Placeholder)
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 40.r,
                backgroundColor: AppColors.cardinal.withOpacity(0.2),
                foregroundImage: profile != null && profile.avatarUrl.isNotEmpty ? NetworkImage(profile.avatarUrl) as ImageProvider : null,
                child: profile == null || profile.avatarUrl.isEmpty ? Icon(Icons.person, size: 50.sp, color: AppColors.cardinal) : null,
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

  // --- 3. NÚT HÀNH ĐỘNG ---
  Widget _buildActionButtons(BuildContext context, ProfileEntity? profile, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        children: [
          // Thống kê theo dõi (labels always blue)
          Row(
            children: [
              // Đang theo dõi (clickable)
              Flexible(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => const FriendsListView(initialTabIndex: 0),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeOut));
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
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.macaw,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${profile?.followingCount ?? 0}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.macaw,
                          fontWeight: FontWeight.bold,
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
                      pageBuilder: (context, animation, secondaryAnimation) => const FriendsListView(initialTabIndex: 1),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeOut));
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
                        '${profile?.followerCount ?? 0}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.macaw,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Flexible(
                        child: Text(
                          'Người theo dõi',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.macaw,
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
          // Nút bấm
          Row(
            children: [
              Expanded(
                child: AppButton(
                  onPressed: () {},
                  // Use primary (blue) variant and include person_add icon before text
                  child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => const FindFriendsView(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeOut));
                            return SlideTransition(position: animation.drive(tween), child: child);
                          },
                          transitionDuration: const Duration(milliseconds: 320),
                        ));
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_add, size: 18.sp, color: AppColors.snow),
                          SizedBox(width: 8.w),
                          Flexible(
                            child: Text(
                              'THÊM BẠN BÈ',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: AppColors.snow,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  variant: ButtonVariant.primary,
                  size: ButtonSize.medium,
                  shadowOpacity: 0.6,
                ),
              ),
              SizedBox(width: 12.w),
              AppButton(
                onPressed: () {},
                child: Icon(Icons.ios_share_outlined, size: 20.sp, color: AppColors.snow),
                variant: ButtonVariant.primary,
                size: ButtonSize.small,
                width: 56.w,
                shadowOpacity: 0.6,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 4. TỔNG QUAN ---
  Widget _buildSectionHeader(BuildContext context, ThemeData theme,
      {required String title, String? actionText, VoidCallback? onActionTap}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: AppColors.bodyText,
            ),
          ),
          if (actionText != null)
            GestureDetector(
              onTap: onActionTap,
              behavior: HitTestBehavior.opaque,
              child: Text(
                actionText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.macaw,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOverviewGrid(BuildContext context, ProfileEntity? profile, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 2.0, // Làm cho thẻ rộng hơn
        children: [
          _StatCard(
            icon: Icon(Icons.whatshot, color: AppColors.fox, size: 28.sp),
            value: '${profile?.streakDays ?? 0}',
            label: 'Ngày streak',
            theme: theme,
          ),
          _StatCard(
            icon: Icon(Icons.flash_on, color: AppColors.bee, size: 28.sp),
            value: '${profile?.totalExp ?? 0} KN',
            label: 'Tổng KN',
            theme: theme,
          ),
          _StatCard(
            icon: Icon(Icons.shield, color: AppColors.wolf, size: 28.sp),
            value: profile != null && profile.isInTournament ? 'Đang tham gia' : 'Chưa tham gia',
            label: 'Giải đấu hiện tại',
            theme: theme,
          ),
          _StatCard(
            // Placeholder cho Cờ
            icon: Image.asset(profile != null ? 'assets/flags/${profile.countryCode}.png' : 'assets/flags/english.png', width: 28.w),
            value: '${profile?.top3Count ?? 0}',
            label: 'Top 3',
            theme: theme,
          ),
        ],
      ),
    );
  }

  // --- 5. STREAK BẠN BÈ ---
  Widget _buildFriendStreak(BuildContext context, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.snow,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.swan, width: 2.w),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title inside the same rounded card so the border encloses it
            Text(
              'Streak bạn bè',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.bodyText,
              ),
            ),
            SizedBox(height: 8.h),
            // Use SingleChildScrollView or reduce circle size for small screens
            LayoutBuilder(
              builder: (context, constraints) {
                // Calculate available width for circles
                final availableWidth = constraints.maxWidth;
                final circleSize = (availableWidth - 32.w) / 5; // 5 circles with minimal spacing
                final safeCircleSize = circleSize.clamp(48.0, 64.0); // Min 48, max 64
                
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _FriendStreakCircle(
                      size: safeCircleSize.w,
                      isToday: true,
                      child: Text(
                        '0',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: AppColors.macaw,
                          fontWeight: FontWeight.bold,
                          fontSize: (safeCircleSize * 0.34).sp, // Scale font with circle
                        ),
                      ),
                    ),
                    _FriendStreakCircle(size: safeCircleSize.w, child: Icon(Icons.add, color: AppColors.wolf, size: (safeCircleSize * 0.47).sp)),
                    _FriendStreakCircle(size: safeCircleSize.w, child: Icon(Icons.add, color: AppColors.wolf, size: (safeCircleSize * 0.47).sp)),
                    _FriendStreakCircle(size: safeCircleSize.w, child: Icon(Icons.add, color: AppColors.wolf, size: (safeCircleSize * 0.47).sp)),
                    _FriendStreakCircle(size: safeCircleSize.w, child: Icon(Icons.add, color: AppColors.wolf, size: (safeCircleSize * 0.47).sp)),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- 6. THÀNH TÍCH ---
  Widget _buildAchievements(BuildContext context, ThemeData theme) {
    // Dữ liệu giả cho thành tích
    final achievements = [
      {'path': 'assets/images/badge1.png', 'level': '10'},
      {'path': 'assets/images/badge2.png', 'level': '100'},
      {'path': 'assets/images/badge3.png', 'level': '3'},
    ];

    return Container(
      height: 150.h, // Chiều cao cố định cho list ngang
      padding: EdgeInsets.only(left: 16.w, top: 8.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: achievements.length,
        itemBuilder: (context, index) {
          final ach = achievements[index];
          // Placeholder cho ảnh thành tích
          return Padding(
            padding: EdgeInsets.only(right: 16.w),
                child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  width: 100.w,
                  height: 100.w,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.swan, width: 1.5.w),
                    color: AppColors.snow,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Image.asset(ach['path']!, width: 100.w, height: 100.w, fit: BoxFit.cover),
                  ),
                ),
                // Nhãn level
                Positioned(
                  bottom: 8.h,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      ach['level']!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.snow,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

// --- WIDGET CON (HELPER) ---

// Thẻ thống kê trong "Tổng quan"
class _StatCard extends StatelessWidget {
  final Widget icon;
  final String value;
  final String label;
  final ThemeData theme;

  const _StatCard({
    Key? key,
    required this.icon,
    required this.value,
    required this.label,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.swan, width: 2.w),
      ),
      child: Row(
        children: [
          // Left: icon area with fixed width for consistent alignment
          SizedBox(
            width: 56.w,
            child: Center(child: icon),
          ),
          SizedBox(width: 12.w),
          // Right: value + label
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min, // ← Prevent overflow
              children: [
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColors.bodyText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h), // ← Reduced from 4.h
                Flexible( // ← Make label flexible
                  child: Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.wolf,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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

// Vòng tròn trong "Streak bạn bè"
class _FriendStreakCircle extends StatelessWidget {
  final Widget child;
  final bool isToday;
  final double size;

  const _FriendStreakCircle({
    Key? key,
    required this.child,
    this.isToday = false,
    this.size = 50,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If it's today's circle, keep the filled style. Otherwise draw a dashed circle.
    if (isToday) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.macaw.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.macaw,
            width: 2.w,
          ),
        ),
        child: Center(child: child),
      );
    }

    return _DashedCircle(size: size, color: AppColors.swan, child: child);
  }
}

// Draw a dashed circular border and center child inside.
class _DashedCircle extends StatelessWidget {
  final double size;
  final Widget child;
  final Color color;

  const _DashedCircle({Key? key, required this.size, required this.child, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DashedCirclePainter(color: color),
        child: Center(child: child),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;

  _DashedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const double strokeWidth = 2.0;
    const double dashLength = 6.0;
    const double gapLength = 4.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final circumference = 2 * math.pi * radius;
    final step = dashLength + gapLength;
    final dashCount = (circumference / step).floor().clamp(4, 360);
    final thetaPerDash = 2 * math.pi / dashCount;
    final dashAngle = thetaPerDash * (dashLength / step);

    double startAngle = -math.pi / 2; // start at top
    for (int i = 0; i < dashCount; i++) {
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, dashAngle, false, paint);
      startAngle += thetaPerDash;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
