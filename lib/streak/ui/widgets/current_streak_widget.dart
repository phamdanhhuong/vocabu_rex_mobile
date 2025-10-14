import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/streak_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'streak_detail_bottom_sheet.dart';

class CurrentStreakWidget extends StatelessWidget {
  final VoidCallback? onTapStreak;

  const CurrentStreakWidget({
    Key? key,
    this.onTapStreak,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StreakBloc, StreakState>(
      builder: (context, state) {
        if (state is StreakLoaded) {
          final streak = state.response.currentStreak.length;
          final isFrozen = state.response.currentStreak.isCurrentlyFrozen;
          // Lấy các ngày streak từ history (từ startDate đến endDate của mỗi entry)
          final streakDays = state.response.history
              .expand((entry) {
                List<DateTime> days = [];
                for (int i = 0; i <= entry.durationDays; i++) {
                  days.add(entry.startDate.add(Duration(days: i)));
                }
                return days;
              })
              .toList();
          // Ngày frozen: nếu đang frozen thì lấy freezeExpiresAt
          final frozenDays = state.response.currentStreak.isCurrentlyFrozen && state.response.currentStreak.freezeExpiresAt != null
              ? [state.response.currentStreak.freezeExpiresAt!]
              : [];
          return GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (ctx) => StreakDetailBottomSheet(
                  streak: streak,
                  isFrozen: isFrozen,
                  streakDays: streakDays,
                  frozenDays: List<DateTime>.from(frozenDays),
                  tabIndex: 0,
                  onTabChanged: (i) {},
                  onExtendStreak: () {},
                ),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/icons/streak.svg',
                  width: 24,
                  height: 24,
                ),
                const SizedBox(width: 4),
                Text('$streak', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
              ],
            ),
          );
        } else if (state is StreakLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is StreakError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        return const SizedBox.shrink();
      },
    );
  }
}
