class StreakStatisticsModel {
  final double averageStreakLength;
  final int totalActiveDays;
  final int totalFreezesUsed;
  final Map<String, int> streakDistribution;

  StreakStatisticsModel({
    required this.averageStreakLength,
    required this.totalActiveDays,
    required this.totalFreezesUsed,
    required this.streakDistribution,
  });

  factory StreakStatisticsModel.fromJson(Map<String, dynamic> json) {
    return StreakStatisticsModel(
      averageStreakLength: (json['averageStreakLength'] as num).toDouble(),
      totalActiveDays: json['totalActiveDays'] as int,
      totalFreezesUsed: json['totalFreezesUsed'] as int,
      streakDistribution: Map<String, int>.from(json['streakDistribution'] as Map),
    );
  }
}
