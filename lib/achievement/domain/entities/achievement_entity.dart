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
        return 'assets/icons/streak.png';
      case 'lessons':
        return 'assets/icons/learn.png';
      case 'xp':
        return 'assets/icons/xp.png';
      case 'social':
        return 'assets/icons/friend.png';
      default:
        return 'assets/icons/reward.png';
    }
  }
}

class AchievementAssetHelper {
  static const Set<String> _multiStateAssets = {
    'cheerleader', 'early_riser', 'flawless_finisher', 'league_mvp', 
    'legend', 'mistake_mechanic', 'no_mistake', 'perfect_week', 
    'quest_explorer', 'rarest_diamond', 'sleepwalker', 'social_butterfly', 
    'speed_racer', 'xp_olympian', 'year_of_the_dragon',
    'highest_league_-_amethyst', 'highest_league_-_bronze', 
    'highest_league_-_diamond', 'highest_league_-_diamond_tournament', 
    'highest_league_-_emerald', 'highest_league_-_gold', 
    'highest_league_-_obsidian', 'highest_league_-_pearl', 
    'highest_league_-_ruby', 'highest_league_-_sapphire', 
    'highest_league_-_silver',
  };

  static const Set<String> _singleStateAssets = {
    'longest_streak', 'most_xp', 'perfect_lessons',
  };

  /// Returns the actual image asset path inside `assets/achievements/`
  /// by smartly mapping the DB keys and categories to existing physical files.
  static String resolveAssetPath(AchievementEntity entity) {
    final ach = entity.achievement;
    final category = ach.category.toLowerCase();
    
    // 1. Extract raw identifier from key
    String baseKey = ach.key.replaceAll(RegExp(r'_t\d+$'), '').toLowerCase();
    
    // 2. Direct exact match check
    if (_singleStateAssets.contains(baseKey)) {
      return 'assets/achievements/$baseKey.png';
    }
    if (_multiStateAssets.contains(baseKey)) {
      return _buildMultiStatePath(baseKey, entity);
    }

    // 3. Fallback smart mapping based on keywords in key, category or name
    final nameLower = ach.name.toLowerCase();
    String mappedBaseName = 'legend'; // Default fallback
    bool useSingleState = false;

    if (baseKey.contains('league') || nameLower.contains('league') || nameLower.contains('giải đấu')) {
      final tier = ach.tier.toString();
      mappedBaseName = 'highest_league_-_bronze';
      if (tier == '2') mappedBaseName = 'highest_league_-_silver';
      if (tier == '3') mappedBaseName = 'highest_league_-_gold';
      if (tier == '4') mappedBaseName = 'highest_league_-_diamond';
      if (tier == '5') mappedBaseName = 'highest_league_-_obsidian';
    } else if (category == 'social' || baseKey.contains('social') || nameLower.contains('friend') || nameLower.contains('bạn bè')) {
      mappedBaseName = 'social_butterfly';
    } else if (category == 'streak' || baseKey.contains('streak') || nameLower.contains('chuỗi')) {
      if (category == 'personal' || ach.requirement > 100) {
        mappedBaseName = 'longest_streak';
        useSingleState = true;
      } else {
        mappedBaseName = 'speed_racer';
      }
    } else if (category == 'xp' || baseKey.contains('xp') || nameLower.contains('kinh nghiệm')) {
      if (category == 'personal') {
        mappedBaseName = 'most_xp';
        useSingleState = true;
      } else {
        mappedBaseName = 'xp_olympian';
      }
    } else if (category == 'lessons' || baseKey.contains('lesson') || nameLower.contains('bài học')) {
      if (category == 'personal') {
        mappedBaseName = 'perfect_lessons';
        useSingleState = true;
      } else {
        mappedBaseName = 'flawless_finisher';
      }
    } else if (baseKey.contains('perfect') || nameLower.contains('hoàn hảo')) {
      mappedBaseName = 'perfect_week';
    } else if (baseKey.contains('quest') || nameLower.contains('nhiệm vụ')) {
      mappedBaseName = 'quest_explorer';
    }

    if (useSingleState || _singleStateAssets.contains(mappedBaseName)) {
      return 'assets/achievements/$mappedBaseName.png';
    }

    return _buildMultiStatePath(mappedBaseName, entity);
  }

  static String _buildMultiStatePath(String baseName, AchievementEntity entity) {
    if (entity.achievement.category.toLowerCase() == 'personal') {
       return 'assets/achievements/$baseName.png';
    }
    
    final req = entity.achievement.requirement;
    final isFull = req > 0 && entity.progress >= req;
    final suffix = isFull ? '_done.png' : '_doing.png';
    return 'assets/achievements/$baseName$suffix';
  }
}
