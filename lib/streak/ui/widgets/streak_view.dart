import 'package:flutter/material.dart';
// dart:math removed (unused)
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/streak/ui/blocs/streak_bloc.dart';
import 'package:vocabu_rex_mobile/streak/ui/widgets/streak_calendar_widget.dart';
import 'package:vocabu_rex_mobile/streak/ui/widgets/streak_app_bar.dart';
import 'package:vocabu_rex_mobile/streak/ui/widgets/streak_header.dart';
import 'package:vocabu_rex_mobile/streak/ui/widgets/streak_card.dart';
import 'streak_tokens.dart';
// (Tokens and componentized widgets live in separate files.)

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
class _StreakCalendar extends StatefulWidget {
  @override
  State<_StreakCalendar> createState() => _StreakCalendarState();
}

class _StreakCalendarState extends State<_StreakCalendar>
    with TickerProviderStateMixin {
  DateTime? _currentMonth;
  DateTime? _selectedDay;
  // -1 = moved to previous (slide from left), 1 = moved to next (slide from right)
  int _slideDirection = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StreakBloc, StreakState>(
      builder: (context, state) {
        if (state is StreakLoaded) {
          final streakDays = state.response.history
              .expand(
                (entry) => List<DateTime>.generate(
                  entry.durationDays,
                  (i) => entry.startDate.add(Duration(days: i)),
                ),
              )
              .toList();

          final frozenDays =
              state.response.currentStreak.freezeExpiresAt != null
              ? [state.response.currentStreak.freezeExpiresAt!]
              : <DateTime>[];

          final initialMonth = streakDays.isNotEmpty
              ? DateTime(streakDays.last.year, streakDays.last.month, 1)
              : DateTime(DateTime.now().year, DateTime.now().month, 1);

          // initialize current month once when the data loads
          _currentMonth ??= initialMonth;

          // Build the calendar inside an AnimatedSize so changes in height
          // animate smoothly, and inside an AnimatedSwitcher to slide between
          // months based on the navigation direction.
          final child = StreakCalendarWidget(
            key: ValueKey('${_currentMonth!.year}-${_currentMonth!.month}'),
            month: _currentMonth!,
            streakDays: streakDays,
            frozenDays: frozenDays,
            onMonthChanged: (m) {
              // determine direction: if m is after current, slide from right (1), else left (-1)
              if (_currentMonth != null) {
                final candidate = DateTime(m.year, m.month, 1);
                if (candidate.isAfter(_currentMonth!)) {
                  _slideDirection = 1;
                } else if (candidate.isBefore(_currentMonth!)) {
                  _slideDirection = -1;
                } else {
                  _slideDirection = 0;
                }
                setState(() => _currentMonth = candidate);
              }
            },
            selectedDay: _selectedDay,
            onDaySelected: (d) => setState(() => _selectedDay = d),
          );

          return StreakCard(
            title: 'Lịch',
            child: AnimatedSize(
              // slowed slightly for a smoother feel
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInOut,
              child: AnimatedSwitcher(
                // slowed and smoothed
                duration: const Duration(milliseconds: 1000),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                transitionBuilder: (Widget childWidget, Animation<double> animation) {
                  // Determine whether the child is the incoming one by checking its key
                  final isIncoming =
                      (childWidget.key ==
                      ValueKey(
                        '${_currentMonth!.year}-${_currentMonth!.month}',
                      ));
                  // incoming should slide from the direction we indicated; outgoing slide opposite
                  final beginOffset = isIncoming
                      ? Offset(_slideDirection.toDouble(), 0)
                      : Offset(-_slideDirection.toDouble(), 0);
                  final offsetAnimation = Tween<Offset>(
                    begin: beginOffset,
                    end: Offset.zero,
                  ).animate(animation);
                  return SlideTransition(
                    position: offsetAnimation,
                    child: FadeTransition(
                      opacity: animation,
                      child: childWidget,
                    ),
                  );
                },
                child: child,
              ),
            ),
          );
        } else if (state is StreakLoading) {
          return StreakCard(title: 'Lịch', child: const Center(child: CircularProgressIndicator()));
        } else if (state is StreakError) {
          return StreakCard(title: 'Lịch', child: Center(child: Text('Error: ${state.message}')));
        }

        return StreakCard(title: 'Lịch', child: const Center(child: CircularProgressIndicator()));
      },
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
