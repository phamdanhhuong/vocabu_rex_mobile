class CurrentStreakModel {
  final int length;
  final DateTime startDate;
  final DateTime? lastStudyDate;
  final int freezesRemaining;
  final bool isCurrentlyFrozen;
  final DateTime? freezeExpiresAt;

  CurrentStreakModel({
    required this.length,
    required this.startDate,
    this.lastStudyDate,
    required this.freezesRemaining,
    required this.isCurrentlyFrozen,
    this.freezeExpiresAt,
  });

  factory CurrentStreakModel.fromJson(Map<String, dynamic> json) {
    return CurrentStreakModel(
      length: json['length'] as int,
      startDate: DateTime.parse(json['startDate'] as String),
      lastStudyDate: json['lastStudyDate'] != null
          ? DateTime.parse(json['lastStudyDate'] as String)
          : null,
      freezesRemaining: json['freezesRemaining'] as int,
      isCurrentlyFrozen: json['isCurrentlyFrozen'] as bool,
      freezeExpiresAt: json['freezeExpiresAt'] != null
          ? DateTime.parse(json['freezeExpiresAt'] as String)
          : null,
    );
  }
}
