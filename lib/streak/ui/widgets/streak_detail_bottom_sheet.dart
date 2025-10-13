import 'package:flutter/material.dart';
import 'streak_header_widget.dart';
import 'streak_frozen_widget.dart';
import 'streak_calendar_widget.dart';
import 'streak_society_widget.dart';

class StreakDetailBottomSheet extends StatelessWidget {
  final int streak;
  final bool isFrozen;
  final List<DateTime> streakDays;
  final List<DateTime> frozenDays;
  final int tabIndex;
  final Function(int)? onTabChanged;
  final VoidCallback? onExtendStreak;

  const StreakDetailBottomSheet({
    Key? key,
    required this.streak,
    this.isFrozen = false,
    this.streakDays = const [],
    this.frozenDays = const [],
    this.tabIndex = 0,
    this.onTabChanged,
    this.onExtendStreak,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: ListView(
            controller: scrollController,
            children: [
              StreakHeaderWidget(
                streakDays: streak,
                tabIndex: tabIndex,
                onTabChanged: onTabChanged ?? (i) {},
              ),
              StreakFrozenWidget(
                isFrozen: isFrozen,
                onExtendStreak: onExtendStreak,
              ),
              StreakCalendarWidget(
                month: DateTime.now(),
                streakDays: streakDays,
                frozenDays: frozenDays,
              ),
              StreakSocietyWidget(
                unlocked: streak >= 7,
              ),
            ],
          ),
        );
      },
    );
  }
}
