class AchievementEntity {
  final String id;
  final String userId;
  final String achievementId;
  final int progress;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final AchievementDetails achievement;

  AchievementEntity({
    required this.id,
    required this.userId,
    required this.achievementId,
    required this.progress,
    required this.isUnlocked,
    this.unlockedAt,
    required this.achievement,
  });
}

class AchievementDetails {
  final String id;
  final String key;
  final String name;
  final String description;
  final String? iconUrl;
  final String? badgeUrl;
  final String category;
  final int tier;
  final int requirement;
  final int rewardXp;
  final int rewardGems;

  AchievementDetails({
    required this.id,
    required this.key,
    required this.name,
    required this.description,
    this.iconUrl,
    this.badgeUrl,
    required this.category,
    required this.tier,
    required this.requirement,
    required this.rewardXp,
    required this.rewardGems,
  });
}
