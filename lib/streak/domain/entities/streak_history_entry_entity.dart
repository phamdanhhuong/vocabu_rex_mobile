class StreakHistoryEntryEntity {
  final String id;
  final int streakLength;
  final DateTime startDate;
  final DateTime endDate;
  final String endReason;
  final int freezesUsed;
  final int durationDays;
  final bool isActive;

  StreakHistoryEntryEntity({
    required this.id,
    required this.streakLength,
    required this.startDate,
    required this.endDate,
    required this.endReason,
    required this.freezesUsed,
    required this.durationDays,
    required this.isActive,
  });
}
