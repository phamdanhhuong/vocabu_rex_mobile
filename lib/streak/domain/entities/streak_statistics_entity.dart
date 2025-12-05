class StreakStatisticsEntity {
  final double averageStreakLength;
  final int totalActiveDays;
  final int totalFreezesUsed;
  final Map<String, int> streakDistribution;

  StreakStatisticsEntity({
    required this.averageStreakLength,
    required this.totalActiveDays,
    required this.totalFreezesUsed,
    required this.streakDistribution,
  });

  Map<String, dynamic> toJson() {
    return {
      'averageStreakLength': averageStreakLength,
      'totalActiveDays': totalActiveDays,
      'totalFreezesUsed': totalFreezesUsed,
      'streakDistribution': streakDistribution,
    };
  }
}
