import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/streak/ui/widgets/streak_calendar_v2_widget.dart';
import 'package:vocabu_rex_mobile/streak/ui/widgets/streak_app_bar.dart';
import 'package:vocabu_rex_mobile/streak/ui/widgets/streak_header.dart';
import 'package:vocabu_rex_mobile/streak/ui/widgets/streak_card.dart';
import 'streak_tokens.dart';

/// Giao diện màn hình "Streak" (Cá nhân).
class StreakView extends StatelessWidget {
  const StreakView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.snow, // Nền
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StreakAppBar(),
            const StreakHeader(),
            _StreakCalendar(),
            _StreakGoalCard(),
            _LockedFeatureCard(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// App bar implementation moved to `streak_app_bar.dart`.


// Header implementation moved to `streak_header.dart`.

// (Info card removed — its content was merged into the header so both
// share the same accent background and layout.)

// --- 4. LỊCH ---
class _StreakCalendar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreakCard(
      title: 'Lịch',
      child: StreakCalendarV2Widget(
        initialMonth: DateTime.now(),
      ),
    );
  }
}

// --- 5. MỤC TIÊU STREAK ---
class _StreakGoalCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreakCard(
      title: 'Mục tiêu Streak',
      child: Column(
        children: [
          // Thanh tiến độ tùy chỉnh — responsive using LayoutBuilder instead of magic width
          LayoutBuilder(builder: (context, constraints) {
            final totalWidth = constraints.maxWidth;
            final progressWidth = totalWidth * (1.0 / 7.0); // 1 of 7
            return Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Nền
                Container(
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.swan,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                // Tiến độ (ví dụ 1/7)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: progressWidth,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.fox,
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
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGoalIcon(String day, {required bool isAchieved}) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isAchieved ? AppColors.fox : AppColors.snow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.swan, width: 2),
      ),
      child:
          // TODO: Thay bằng icon lịch (ảnh)
          Text(
            day,
            style: TextStyle(
              color: isAchieved ? AppColors.snow : AppColors.wolf,
              fontWeight: FontWeight.bold,
            ),
          ),
    );
  }
}

// --- 6. HỘI STREAK ---
class _LockedFeatureCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreakCard(
      title: 'Hội Streak',
      child: Row(
        children: [
          // TODO: Thay bằng ảnh ổ khóa
          Icon(Icons.lock, size: kLockedIconSize, color: AppColors.wolf),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Đạt 7 ngày streak để gia nhập Hội Streak và nhận những phần thưởng độc quyền.',
              style: TextStyle(
                color: AppColors.wolf,
                fontSize: kLockedTextFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// StreakCard provides the shared card look; implementation lives in streak_card.dart
