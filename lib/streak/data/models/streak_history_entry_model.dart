class StreakHistoryEntryModel {
  final String id;
  final int streakLength;
  final DateTime startDate;
  final DateTime endDate;
  final String endReason;
  final int freezesUsed;
  final int durationDays;
  final bool isActive;

  StreakHistoryEntryModel({
    required this.id,
    required this.streakLength,
    required this.startDate,
    required this.endDate,
    required this.endReason,
    required this.freezesUsed,
    required this.durationDays,
    required this.isActive,
  });

  factory StreakHistoryEntryModel.fromJson(Map<String, dynamic> json) {
    return StreakHistoryEntryModel(
      id: json['id'] as String,
      streakLength: json['streakLength'] as int,
      startDate: DateTime.parse(json['startDate'] as String).toLocal(),
      endDate: DateTime.parse(json['endDate'] as String).toLocal(),
      endReason: json['endReason'] as String,
      freezesUsed: json['freezesUsed'] as int,
      durationDays: json['durationDays'] as int,
      isActive: json['isActive'] as bool,
    );
  }
}
