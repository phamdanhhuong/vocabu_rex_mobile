import 'package:vocabu_rex_mobile/profile/domain/entities/achievement_entity.dart';

class AchievementModel {
  final String id;
  final String userId;
  final String achievementId;
  final int progress;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final AchievementDetailsModel achievement;

  AchievementModel({
    required this.id,
    required this.userId,
    required this.achievementId,
    required this.progress,
    required this.isUnlocked,
    this.unlockedAt,
    required this.achievement,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      achievementId: json['achievementId'] as String,
      progress: json['progress'] as int? ?? 0,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] != null 
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
      achievement: AchievementDetailsModel.fromJson(json['achievement'] as Map<String, dynamic>),
    );
  }

  AchievementEntity toEntity() {
    return AchievementEntity(
      id: id,
      userId: userId,
      achievementId: achievementId,
      progress: progress,
      isUnlocked: isUnlocked,
      unlockedAt: unlockedAt,
      achievement: achievement.toEntity(),
    );
  }
}

class AchievementDetailsModel {
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

  AchievementDetailsModel({
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

  factory AchievementDetailsModel.fromJson(Map<String, dynamic> json) {
    return AchievementDetailsModel(
      id: json['id'] as String,
      key: json['key'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconUrl: json['iconUrl'] as String?,
      badgeUrl: json['badgeUrl'] as String?,
      category: json['category'] as String,
      tier: json['tier'] as int? ?? 1,
      requirement: json['requirement'] as int? ?? 0,
      rewardXp: json['rewardXp'] as int? ?? 0,
      rewardGems: json['rewardGems'] as int? ?? 0,
    );
  }

  AchievementDetails toEntity() {
    return AchievementDetails(
      id: id,
      key: key,
      name: name,
      description: description,
      iconUrl: iconUrl,
      badgeUrl: badgeUrl,
      category: category,
      tier: tier,
      requirement: requirement,
      rewardXp: rewardXp,
      rewardGems: rewardGems,
    );
  }
}
