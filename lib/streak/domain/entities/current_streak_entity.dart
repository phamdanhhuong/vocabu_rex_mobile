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

  Map<String, dynamic> toJson() {
    return {
      'length': length,
      'startDate': startDate.toIso8601String(),
      'lastStudyDate': lastStudyDate?.toIso8601String(),
      'freezesRemaining': freezesRemaining,
      'isCurrentlyFrozen': isCurrentlyFrozen,
      'freezeExpiresAt': freezeExpiresAt?.toIso8601String(),
    };
  }
}
