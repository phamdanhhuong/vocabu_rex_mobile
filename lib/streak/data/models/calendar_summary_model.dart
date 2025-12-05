class CalendarSummaryModel {
  final int totalDays;
  final int activeDays;
  final int frozenDays;
  final int missedDays;
  final int currentStreak;
  final int longestStreakInRange;

  CalendarSummaryModel({
    required this.totalDays,
    required this.activeDays,
    required this.frozenDays,
    required this.missedDays,
    required this.currentStreak,
    required this.longestStreakInRange,
  });

  factory CalendarSummaryModel.fromJson(Map<String, dynamic> json) {
    return CalendarSummaryModel(
      totalDays: json['totalDays'] as int,
      activeDays: json['activeDays'] as int,
      frozenDays: json['frozenDays'] as int,
      missedDays: json['missedDays'] as int,
      currentStreak: json['currentStreak'] as int,
      longestStreakInRange: json['longestStreakInRange'] as int,
    );
  }
}
