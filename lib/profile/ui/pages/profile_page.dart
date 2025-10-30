import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/achievement/ui/widgets/all_achievements_view.dart';
import 'package:vocabu_rex_mobile/friend/ui/widgets/find_friends_view.dart';
import 'package:vocabu_rex_mobile/friend/ui/widgets/friends_list_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/profile/ui/blocs/profile_bloc.dart';
import 'package:vocabu_rex_mobile/profile/domain/entities/profile_entity.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/app_button.dart';

// --- Định nghĩa màu sắc mới dựa trên ảnh (Profile Screen) ---
const Color _profileButtonBorder = Color(0xFFE5E5E5); // Giống swan
const Color _profileGrayText = Color(0xFF777777); // Giống wolf
const Color _profileBlueText = Color(0xFF1CB0F6); // Giống macaw
const Color _profileCardBackground = Color(0xFFFFFFFF);
const Color _profilePageBackground = Color(0xFFFFFFFF);

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
      color: _profilePageBackground,
      child: SingleChildScrollView(
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (state is ProfileError) {
              return Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(child: Text('Error: ${state.message}')),
              );
            }

            final ProfileEntity? profile = state is ProfileLoaded ? state.profile : null;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. App Bar (Hồ sơ + Cài đặt)
                _buildAppBar(context),

                // 2. Thông tin cá nhân
                _buildUserInfo(context, profile),

                // Divider + Action buttons
                const Divider(color: _profileButtonBorder),
                _buildActionButtons(context, profile),
                const Divider(color: _profileButtonBorder),

                // 4. Mục "Tổng quan"
                _buildSectionHeader(context, title: 'Tổng quan'),
                _buildOverviewGrid(context, profile),

                // 5. Mục "Streak bạn bè"
                _buildFriendStreak(context),

                // 6. Mục "Thành tích"
                _buildSectionHeader(
                  context,
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
                _buildAchievements(context),
              ],
            );
          },
        ),
      ),
    );
  }
  // --- 1. APP BAR ---
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0)
          .copyWith(top: 16.0), // Thêm padding trên
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 40), // Placeholder cho cân bằng
          const Text(
            'Hồ sơ',
            style: TextStyle(
              color: AppColors.bodyText,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: _profileBlueText, size: 28),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // --- 2. THÔNG TIN CÁ NHÂN ---
  Widget _buildUserInfo(BuildContext context, ProfileEntity? profile) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // Cột Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile?.displayName ?? 'Người dùng',
                  style: const TextStyle(
                    color: AppColors.bodyText,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile?.username ?? '',
                  style: const TextStyle(color: _profileGrayText, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  profile != null ? 'Đã tham gia ${profile.joinedDate}' : '',
                  style: const TextStyle(color: _profileGrayText, fontSize: 16),
                ),
                const SizedBox(height: 8),
                // Placeholder cho lá cờ
                Image.asset(profile != null ? 'assets/flags/${profile.countryCode}.png' : 'assets/flags/english.png', width: 96),
              ],
            ),
          ),
          // Avatar (Placeholder)
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.purple[100],
                foregroundImage: profile != null && profile.avatarUrl.isNotEmpty ? NetworkImage(profile.avatarUrl) as ImageProvider : null,
                child: profile == null || profile.avatarUrl.isEmpty ? Icon(Icons.person, size: 50, color: Colors.purple[800]) : null,
              ),
              Positioned(
                top: -4,
                right: -4,
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: _profileBlueText,
                  child: Icon(Icons.edit, color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 3. NÚT HÀNH ĐỘNG ---
  Widget _buildActionButtons(BuildContext context, ProfileEntity? profile) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        children: [
          // Thống kê theo dõi (labels always blue)
          Row(
            children: [
              // Đang theo dõi (clickable)
              GestureDetector(
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
                  children: [
                    Text('Đang theo dõi ', style: const TextStyle(color: _profileBlueText, fontSize: 16)),
                    Text('${profile?.followingCount ?? 0}', style: const TextStyle(color: _profileBlueText, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Người theo dõi (clickable)
              GestureDetector(
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
                  children: [
                    Text('${profile?.followerCount ?? 0}', style: const TextStyle(color: _profileBlueText, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(width: 6),
                    const Text('Người theo dõi', style: TextStyle(color: _profileBlueText, fontSize: 16)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
                        children: const [
                          Icon(Icons.person_add, size: 18, color: Colors.white),
                          SizedBox(width: 8),
                          Text('THÊM BẠN BÈ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  variant: ButtonVariant.primary,
                  size: ButtonSize.medium,
                  shadowOpacity: 0.6,
                ),
              ),
              const SizedBox(width: 12),
              AppButton(
                onPressed: () {},
                child: const Icon(Icons.ios_share_outlined, size: 20, color: Colors.white),
                variant: ButtonVariant.primary,
                size: ButtonSize.small,
                width: 56,
                shadowOpacity: 0.6,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 4. TỔNG QUAN ---
  Widget _buildSectionHeader(BuildContext context,
      {required String title, String? actionText, VoidCallback? onActionTap}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
                color: AppColors.bodyText,
                fontSize: 22,
                fontWeight: FontWeight.bold),
          ),
          if (actionText != null)
            GestureDetector(
              onTap: onActionTap,
              behavior: HitTestBehavior.opaque,
              child: Text(
                actionText,
                style: const TextStyle(
                    color: _profileBlueText,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOverviewGrid(BuildContext context, ProfileEntity? profile) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        childAspectRatio: 2.0, // Làm cho thẻ rộng hơn
        children: [
          _StatCard(
            icon: Icon(Icons.whatshot, color: Colors.orange[600], size: 28),
            value: '${profile?.streakDays ?? 0}',
            label: 'Ngày streak',
          ),
          _StatCard(
            icon: Icon(Icons.flash_on, color: Colors.yellow[700], size: 28),
            value: '${profile?.totalExp ?? 0} KN',
            label: 'Tổng KN',
          ),
          _StatCard(
            icon: Icon(Icons.shield, color: _profileGrayText, size: 28),
            value: profile != null && profile.isInTournament ? 'Đang tham gia' : 'Chưa tham gia',
            label: 'Giải đấu hiện tại',
          ),
          _StatCard(
            // Placeholder cho Cờ
            icon: Image.asset(profile != null ? 'assets/flags/${profile.countryCode}.png' : 'assets/flags/english.png', width: 28),
            value: '${profile?.top3Count ?? 0}',
            label: 'Top 3',
          ),
        ],
      ),
    );
  }

  // --- 5. STREAK BẠN BÈ ---
  Widget _buildFriendStreak(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: _profileCardBackground,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: _profileButtonBorder, width: 2.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title inside the same rounded card so the border encloses it
            const Text('Streak bạn bè', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.bodyText)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _FriendStreakCircle(
                  size: 64,
                  isToday: true,
                  child: const Text('0',
                      style: TextStyle(
                          color: _profileBlueText,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                ),
                _FriendStreakCircle(size: 64, child: const Icon(Icons.add, color: _profileGrayText, size: 30)),
                _FriendStreakCircle(size: 64, child: const Icon(Icons.add, color: _profileGrayText, size: 30)),
                _FriendStreakCircle(size: 64, child: const Icon(Icons.add, color: _profileGrayText, size: 30)),
                _FriendStreakCircle(size: 64, child: const Icon(Icons.add, color: _profileGrayText, size: 30)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- 6. THÀNH TÍCH ---
  Widget _buildAchievements(BuildContext context) {
    // Dữ liệu giả cho thành tích
    final achievements = [
      {'path': 'assets/images/badge1.png', 'level': '10'},
      {'path': 'assets/images/badge2.png', 'level': '100'},
      {'path': 'assets/images/badge3.png', 'level': '3'},
    ];

    return Container(
      height: 150, // Chiều cao cố định cho list ngang
      padding: const EdgeInsets.only(left: 16.0, top: 8.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: achievements.length,
        itemBuilder: (context, index) {
          final ach = achievements[index];
          // Placeholder cho ảnh thành tích
          return Padding(
            padding: const EdgeInsets.only(right: 16.0),
                child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _profileButtonBorder, width: 1.5),
                    color: Colors.white,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(ach['path']!, width: 100, height: 100, fit: BoxFit.cover),
                  ),
                ),
                // Nhãn level
                Positioned(
                  bottom: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      ach['level']!,
                      style: const TextStyle(
                        color: Colors.white,
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

  const _StatCard({
    Key? key,
    required this.icon,
    required this.value,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: _profileCardBackground,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: _profileButtonBorder, width: 2.0),
      ),
      child: Row(
        children: [
          // Left: icon area with fixed width for consistent alignment
          SizedBox(
            width: 56,
            child: Center(child: icon),
          ),
          const SizedBox(width: 12),
          // Right: value + label
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                      color: AppColors.bodyText,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(color: _profileGrayText, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
          color: _profileBlueText.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(
            color: _profileBlueText,
            width: 2.0,
          ),
        ),
        child: Center(child: child),
      );
    }

    return _DashedCircle(size: size, color: _profileButtonBorder, child: child);
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
