class UseStreakFreezeResponseEntity {
  final String userId;
  final int freezesRemaining;
  final DateTime freezeExpiresAt;
  final int currentStreak;
  final int freezeDurationHours;
  final bool success;
  final String? error;

  UseStreakFreezeResponseEntity({
    required this.userId,
    required this.freezesRemaining,
    required this.freezeExpiresAt,
    required this.currentStreak,
    required this.freezeDurationHours,
    required this.success,
    this.error,
  });
}
