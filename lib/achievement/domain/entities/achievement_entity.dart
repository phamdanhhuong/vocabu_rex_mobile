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

  // Calculate progress percentage
  double get progressPercentage {
    if (achievement.requirement == 0) return 0.0;
    return (progress / achievement.requirement).clamp(0.0, 1.0);
  }

  // Check if achievement is in progress (not locked, not unlocked)
  bool get isInProgress {
    return progress > 0 && !isUnlocked;
  }
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

  // Get tier level label
  String get tierLabel {
    switch (tier) {
      case 1:
        return 'Bronze';
      case 2:
        return 'Silver';
      case 3:
        return 'Gold';
      case 4:
        return 'Platinum';
      case 5:
        return 'Diamond';
      default:
        return 'Tier $tier';
    }
  }

  // Get category icon name
  String get categoryIcon {
    switch (category.toLowerCase()) {
      case 'streak':
        return 'assets/images/badge_streak.png';
      case 'lessons':
        return 'assets/images/badge_lesson.png';
      case 'xp':
        return 'assets/images/badge_xp.png';
      case 'social':
        return 'assets/images/badge_social.png';
      default:
        return 'assets/images/badge_default.png';
    }
  }
}
