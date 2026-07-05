/// Entity kết quả sau khi submit minigame
class MiniGameResultEntity {
  final bool success;
  final int newStars;
  final int totalStars;
  final bool isNewHighScore;
  final int rewardedCoins;
  // Score, time, mistakes từ local tracking
  final int score;
  final int timeSpentMs;
  final int mistakesCount;

  const MiniGameResultEntity({
    required this.success,
    required this.newStars,
    required this.totalStars,
    required this.isNewHighScore,
    required this.rewardedCoins,
    required this.score,
    required this.timeSpentMs,
    required this.mistakesCount,
  });

  factory MiniGameResultEntity.fromJson(
    Map<String, dynamic> json, {
    required int score,
    required int timeSpentMs,
    required int mistakesCount,
  }) {
    return MiniGameResultEntity(
      success: json['success'] as bool? ?? false,
      newStars: (json['newStars'] as num?)?.toInt() ?? 0,
      totalStars: (json['totalStars'] as num?)?.toInt() ?? 0,
      isNewHighScore: json['isNewHighScore'] as bool? ?? false,
      rewardedCoins: (json['rewardedCoins'] as num?)?.toInt() ?? 0,
      score: score,
      timeSpentMs: timeSpentMs,
      mistakesCount: mistakesCount,
    );
  }
}
