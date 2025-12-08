import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/streak_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'streak_detail_bottom_sheet.dart';
import '../blocs/streak_event.dart';
import 'package:vocabu_rex_mobile/home/ui/widgets/dot_loading_indicator.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

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
          // Use durationDays from backend instead of calculating manually
          // This ensures timezone-safe date handling
          final streakDays = state.response.history
              .where((entry) => entry.isActive)
              .expand((entry) {
                return List<DateTime>.generate(
                  entry.durationDays,
                  (i) => DateTime(
                    entry.startDate.year,
                    entry.startDate.month,
                    entry.startDate.day + i,
                  ),
                );
              })
              .toList();
          // Frozen days: get from freezeExpiresAt if currently frozen
          final frozenDays = state.response.currentStreak.freezeExpiresAt != null
              ? [state.response.currentStreak.freezeExpiresAt!]
              : <DateTime>[];
          final freezesRemaining = state.response.currentStreak.freezesRemaining;
          // Use current date for initial month if no streak days
          final initialMonth = streakDays.isNotEmpty 
              ? DateTime(streakDays.last.year, streakDays.last.month, 1) 
              : DateTime.now();
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
                  initialMonth: initialMonth,
                  freezesRemaining: freezesRemaining,
                  tabIndex: 0,
                  onTabChanged: (i) {},
                  onExtendStreak: () {
                    context.read<StreakBloc>().add(UseStreakFreezeEvent());
                  },
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
          return Center(
            child: DotLoadingIndicator(
              color: Colors.orange,
              size: 12.0,
            ),
          );
        } else if (state is StreakError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        return const SizedBox.shrink();
      },
    );
  }
}
