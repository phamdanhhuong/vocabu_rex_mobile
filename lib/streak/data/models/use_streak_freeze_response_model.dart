class UseStreakFreezeResponseModel {
  final String userId;
  final int freezesRemaining;
  final DateTime freezeExpiresAt;
  final int currentStreak;
  final int freezeDurationHours;
  final bool success;
  final String? error;

  UseStreakFreezeResponseModel({
    required this.userId,
    required this.freezesRemaining,
    required this.freezeExpiresAt,
    required this.currentStreak,
    required this.freezeDurationHours,
    required this.success,
    this.error,
  });

  factory UseStreakFreezeResponseModel.fromJson(Map<String, dynamic> json) {
    return UseStreakFreezeResponseModel(
      userId: json['userId'] as String,
      freezesRemaining: json['freezesRemaining'] as int,
      freezeExpiresAt: DateTime.parse(json['freezeExpiresAt'] as String),
      currentStreak: json['currentStreak'] as int,
      freezeDurationHours: json['freezeDurationHours'] as int,
      success: json['success'] as bool,
      error: json['error'] as String?,
    );
  }
}
