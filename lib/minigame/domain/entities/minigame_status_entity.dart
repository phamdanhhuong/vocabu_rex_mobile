/// Trạng thái kỷ lục của user cho 1 game type + 1 part
class MiniGameStatusEntity {
  final String gameType;
  final int stars;
  final int bestScore;
  final int? bestTimeMs;
  final int playCount;

  const MiniGameStatusEntity({
    required this.gameType,
    required this.stars,
    required this.bestScore,
    this.bestTimeMs,
    required this.playCount,
  });

  factory MiniGameStatusEntity.fromJson(Map<String, dynamic> json) {
    return MiniGameStatusEntity(
      gameType: json['gameType'] as String? ?? '',
      stars: (json['stars'] as num?)?.toInt() ?? 0,
      bestScore: (json['bestScore'] as num?)?.toInt() ?? 0,
      bestTimeMs: (json['bestTimeMs'] as num?)?.toInt(),
      playCount: (json['playCount'] as num?)?.toInt() ?? 0,
    );
  }
}
