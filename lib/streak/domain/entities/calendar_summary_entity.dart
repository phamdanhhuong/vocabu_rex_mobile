class CalendarSummaryEntity {
  final int totalDays;
  final int activeDays;
  final int frozenDays;
  final int missedDays;
  final int currentStreak;
  final int longestStreakInRange;

  CalendarSummaryEntity({
    required this.totalDays,
    required this.activeDays,
    required this.frozenDays,
    required this.missedDays,
    required this.currentStreak,
    required this.longestStreakInRange,
  });
}
