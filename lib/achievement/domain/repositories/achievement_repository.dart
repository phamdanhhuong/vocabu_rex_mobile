import 'package:vocabu_rex_mobile/achievement/domain/entities/achievement_entity.dart';

abstract class AchievementRepository {
  /// Get all achievements for the current user
  /// If [onlyUnlocked] is true, only return unlocked achievements
  Future<List<AchievementEntity>> getAchievements({bool onlyUnlocked = false});

  /// Get achievements grouped by category
  Future<Map<String, List<AchievementEntity>>> getAchievementsByCategory({
    bool onlyUnlocked = false,
  });

  /// Get recent achievements (for records section)
  Future<List<AchievementEntity>> getRecentAchievements({int limit = 3});

  /// Get achievements summary (personal + highest tier for each category)
  Future<Map<String, List<AchievementEntity>>> getAchievementsSummary();
}
