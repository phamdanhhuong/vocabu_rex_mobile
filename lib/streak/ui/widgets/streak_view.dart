import 'package:flutter/material.dart';
import 'dart:math'; // Cần cho icon
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/streak/ui/blocs/streak_bloc.dart';
import 'package:vocabu_rex_mobile/streak/ui/widgets/streak_calendar_widget.dart';

// --- Định nghĩa màu sắc mới dựa trên ảnh (Light Mode / Streak) ---
const Color _streakBlueLight = Color(0xFFDDF4FF); // Giống selectionBlueLight
const Color _streakBlueDark = Color(0xFF1CB0F6); // Giống macaw
const Color _streakBlueText = Color(0xFF008CCF);
const Color _streakOrange = Color(0xFFFF9600); // Giống fox
const Color _streakGray = Color(0xFF777777); // Giống wolf
const Color _streakCardBorder = Color(0xFFE5E5E5); // Giống swan
const Color _streakBackground = Color(0xFFF7F7F7); // Giống polar

/// Giao diện màn hình "Streak" (Cá nhân).
class StreakView extends StatelessWidget {
  const StreakView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _streakBackground, // Nền xám rất nhạt
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. App Bar tùy chỉnh (Cá nhân / Bạn bè)
            const _StreakAppBar(),

            // 2. Tiêu đề "1 ngày streak"
            const _StreakHeader(),

            // 3. Thẻ thông báo Đóng băng
            const _StreakInfoCard(),

            // 4. Lịch
            _StreakCalendar(),

            // 5. Mục tiêu Streak
            _StreakGoalCard(),

            // 6. Hội Streak
            _LockedFeatureCard(),

            // Thêm padding dưới cùng
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// --- 1. APP BAR TÙY CHỈNH ---
// Widget này cần là StatefulWidget để quản lý tab đang chọn
class _StreakAppBar extends StatefulWidget {
  const _StreakAppBar({Key? key}) : super(key: key);

  @override
  State<_StreakAppBar> createState() => _StreakAppBarState();
}

class _StreakAppBarState extends State<_StreakAppBar> {
  int _selectedIndex = 0; // 0 = Cá nhân, 1 = Bạn bè

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.snow, // Nền trắng
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        children: [
          // Tiêu đề "Streak" và nút X
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Opacity(
                  opacity: 0, // Placeholder
                  child: Icon(Icons.close, size: 28),
                ),
                const Text(
                  'Streak',
                  style: TextStyle(
                    color: AppColors.bodyText,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close,
                      color: AppColors.hare, size: 28),
                  onPressed: () {
                    // Close the streak view and let the route play its reverse animation.
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Hai tab
          Row(
            children: [
              _buildTabItem('CÁ NHÂN', 0),
              _buildTabItem('BẠN BÈ', 1),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, int index) {
    final bool isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          padding: const EdgeInsets.only(bottom: 12.0),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? _streakBlueDark : Colors.transparent,
                width: 2.0,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? _streakBlueDark : _streakGray,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

// --- 2. TIÊU ĐỀ STREAK ---
class _StreakHeader extends StatelessWidget {
  const _StreakHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '1 ngày streak',
            style: TextStyle(
              color: _streakBlueDark,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          // TODO: Thay bằng ảnh icon streak
          Icon(Icons.shield, color: _streakBlueDark, size: 48),
        ],
      ),
    );
  }
}

// --- 3. THẺ THÔNG BÁO ---
class _StreakInfoCard extends StatelessWidget {
  const _StreakInfoCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: _streakBlueLight,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        children: [
          // TODO: Thay bằng ảnh icon check
          const Icon(Icons.check_circle, color: _streakBlueDark, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hôm qua streak của bạn đã được đóng băng.',
                  style: TextStyle(
                    color: _streakBlueText,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Tới lúc nối dài streak rồi!',
                  style: TextStyle(
                    color: _streakBlueText,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'NỐI DÀI STREAK',
                  style: TextStyle(
                    color: _streakBlueDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
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

// --- 4. LỊCH ---
class _StreakCalendar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StreakBloc, StreakState>(
      builder: (context, state) {
        if (state is StreakLoaded) {
          final streakDays = state.response.history
              .expand((entry) => List<DateTime>.generate(
                    entry.durationDays,
                    (i) => entry.startDate.add(Duration(days: i)),
                  ))
              .toList();

          final frozenDays = state.response.currentStreak.freezeExpiresAt != null
              ? [state.response.currentStreak.freezeExpiresAt!]
              : <DateTime>[];

          final initialMonth = streakDays.isNotEmpty
              ? DateTime(streakDays.last.year, streakDays.last.month, 1)
              : DateTime.now();

          return _buildCard(
            title: 'Lịch',
            child: StreakCalendarWidget(
              month: initialMonth,
              streakDays: streakDays,
              frozenDays: frozenDays,
              onMonthChanged: (m) {},
              selectedDay: null,
              onDaySelected: (d) {},
            ),
          );
        } else if (state is StreakLoading) {
          return _buildCard(
            title: 'Lịch',
            child: const Center(child: CircularProgressIndicator()),
          );
        } else if (state is StreakError) {
          return _buildCard(
            title: 'Lịch',
            child: Center(child: Text('Error: ${state.message}')),
          );
        }

        return _buildCard(
          title: 'Lịch',
          child: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

// --- 5. MỤC TIÊU STREAK ---
class _StreakGoalCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _buildCard(
      title: 'Mục tiêu Streak',
      child: Column(
        children: [
          // Thanh tiến độ tùy chỉnh
          Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Nền
              Container(
                height: 16,
                decoration: BoxDecoration(
                  color: _streakCardBorder,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              // Tiến độ (ví dụ 1/7)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 1.0 / 7.0 * 300, // Chiều rộng động (cần LayoutBuilder)
                height: 16,
                decoration: BoxDecoration(
                  color: _streakOrange,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              // Các icon đầu cuối
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // TODO: Thay bằng ảnh lịch 1
                    _buildGoalIcon('1', isAchieved: true),
                    // TODO: Thay bằng ảnh lịch 7
                    _buildGoalIcon('7', isAchieved: false),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalIcon(String day, {required bool isAchieved}) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isAchieved ? _streakOrange : AppColors.snow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _streakCardBorder, width: 2),
      ),
      child:
          // TODO: Thay bằng icon lịch (ảnh)
          Text(
        day,
        style: TextStyle(
            color: isAchieved ? AppColors.snow : _streakGray,
            fontWeight: FontWeight.bold),
      ),
    );
  }
}

// --- 6. HỘI STREAK ---
class _LockedFeatureCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _buildCard(
      title: 'Hội Streak',
      child: Row(
        children: [
          // TODO: Thay bằng ảnh ổ khóa
          Icon(Icons.lock, size: 48, color: _streakGray),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Đạt 7 ngày streak để gia nhập Hội Streak và nhận những phần thưởng độc quyền.',
              style: TextStyle(
                color: _streakGray,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- WIDGET HELPER (CHA) CHO CÁC THẺ ---
Widget _buildCard({required String title, required Widget child}) {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
    padding: const EdgeInsets.all(16.0),
    decoration: BoxDecoration(
      color: AppColors.snow,
      borderRadius: BorderRadius.circular(16.0),
      border: Border.all(color: _streakCardBorder, width: 2.0),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.bodyText,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        child,
      ],
    ),
  );
}
