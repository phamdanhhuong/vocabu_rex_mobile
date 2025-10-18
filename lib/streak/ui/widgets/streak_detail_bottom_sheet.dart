import 'package:flutter/material.dart';
import 'streak_header_widget.dart';
import 'streak_frozen_widget.dart';
import 'streak_calendar_widget.dart';
import 'streak_society_widget.dart';

class StreakDetailBottomSheet extends StatefulWidget {
  final int streak;
  final bool isFrozen;
  final List<DateTime> streakDays;
  final List<DateTime> frozenDays;
  final DateTime? initialMonth;
  final int freezesRemaining;
  final int tabIndex;
  final Function(int)? onTabChanged;
  final VoidCallback? onExtendStreak;

  const StreakDetailBottomSheet({
    Key? key,
    required this.streak,
    this.isFrozen = false,
    this.streakDays = const [],
    this.frozenDays = const [],
    this.initialMonth,
    this.freezesRemaining = 0,
    this.tabIndex = 0,
    this.onTabChanged,
    this.onExtendStreak,
  }) : super(key: key);

  @override
  State<StreakDetailBottomSheet> createState() => _StreakDetailBottomSheetState();
}

class _StreakDetailBottomSheetState extends State<StreakDetailBottomSheet> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
  }

  void _handleMonthChanged(DateTime newMonth) {
    setState(() {
      _currentMonth = newMonth;
    });
  }

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
                streakDays: widget.streak,
                tabIndex: widget.tabIndex,
                onTabChanged: widget.onTabChanged ?? (i) {},
              ),
              StreakFrozenWidget(
                isFrozen: widget.isFrozen,
                freezesRemaining: widget.freezesRemaining,
                onExtendStreak: widget.onExtendStreak,
              ),
              StreakCalendarWidget(
                month: _currentMonth,
                streakDays: widget.streakDays,
                frozenDays: widget.frozenDays,
                onMonthChanged: _handleMonthChanged,
              ),
              StreakSocietyWidget(
                unlocked: widget.streak >= 7,
              ),
            ],
          ),
        );
      },
    );
  }
}
