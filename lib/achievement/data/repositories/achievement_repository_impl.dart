import 'package:vocabu_rex_mobile/achievement/data/datasources/achievement_datasource.dart';
import 'package:vocabu_rex_mobile/achievement/domain/entities/achievement_entity.dart';
import 'package:vocabu_rex_mobile/achievement/domain/repositories/achievement_repository.dart';

class AchievementRepositoryImpl implements AchievementRepository {
  final AchievementDataSource dataSource;

  AchievementRepositoryImpl(this.dataSource);

  @override
  Future<List<AchievementEntity>> getAchievements({
    bool onlyUnlocked = false,
  }) async {
    final models = await dataSource.getAchievements(
      onlyUnlocked: onlyUnlocked,
    );
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Map<String, List<AchievementEntity>>> getAchievementsByCategory({
    bool onlyUnlocked = false,
  }) async {
    final achievements = await getAchievements(onlyUnlocked: onlyUnlocked);
    final Map<String, List<AchievementEntity>> grouped = {};

    for (final achievement in achievements) {
      final category = achievement.achievement.category;
      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }
      grouped[category]!.add(achievement);
    }

    // Sort achievements within each category by tier and progress
    for (final category in grouped.keys) {
      grouped[category]!.sort((a, b) {
        // Unlocked achievements first
        if (a.isUnlocked != b.isUnlocked) {
          return a.isUnlocked ? -1 : 1;
        }
        // Then by tier
        final tierCompare = a.achievement.tier.compareTo(b.achievement.tier);
        if (tierCompare != 0) return tierCompare;
        // Then by progress
        return b.progress.compareTo(a.progress);
      });
    }

    return grouped;
  }

  @override
  Future<List<AchievementEntity>> getRecentAchievements({
    int limit = 3,
  }) async {
    final achievements = await getAchievements(onlyUnlocked: true);

    // Sort by unlocked date (most recent first)
    achievements.sort((a, b) {
      if (a.unlockedAt == null && b.unlockedAt == null) return 0;
      if (a.unlockedAt == null) return 1;
      if (b.unlockedAt == null) return -1;
      return b.unlockedAt!.compareTo(a.unlockedAt!);
    });

    // Return only the most recent ones
    return achievements.take(limit).toList();
  }

  @override
  Future<Map<String, List<AchievementEntity>>> getAchievementsSummary() async {
    final summary = await dataSource.getAchievementsSummary();
    
    return {
      'personal': summary['personal']!.map((model) => model.toEntity()).toList(),
      'awards': summary['awards']!.map((model) => model.toEntity()).toList(),
    };
  }
}
