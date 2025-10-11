class CurrentStreakEntity {
  final int length;
  final DateTime startDate;
  final DateTime? lastStudyDate;
  final int freezesRemaining;
  final bool isCurrentlyFrozen;
  final DateTime? freezeExpiresAt;

  CurrentStreakEntity({
    required this.length,
    required this.startDate,
    this.lastStudyDate,
    required this.freezesRemaining,
    required this.isCurrentlyFrozen,
    this.freezeExpiresAt,
  });
}
