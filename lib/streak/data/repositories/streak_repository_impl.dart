import 'package:vocabu_rex_mobile/streak/domain/entities/get_streak_history_response_entity.dart';
import 'package:vocabu_rex_mobile/streak/domain/entities/current_streak_entity.dart';
import 'package:vocabu_rex_mobile/streak/domain/entities/streak_history_entry_entity.dart';
import 'package:vocabu_rex_mobile/streak/domain/entities/streak_statistics_entity.dart';
import 'package:vocabu_rex_mobile/streak/domain/repositories/streak_repository.dart';
import '../datasources/streak_datasource.dart';

class StreakRepositoryImpl implements StreakRepository {
  final StreakDataSource remoteDataSource;

  StreakRepositoryImpl({required this.remoteDataSource});

  @override
  Future<GetStreakHistoryResponseEntity> getStreakHistory({
    int? limit,
    bool? includeCurrentStreak,
  }) async {
    final model = await remoteDataSource.getStreakHistory(limit: limit, includeCurrentStreak: includeCurrentStreak);
    return GetStreakHistoryResponseEntity(
      userId: model.userId,
      currentStreak: CurrentStreakEntity(
        length: model.currentStreak.length,
        startDate: model.currentStreak.startDate,
        lastStudyDate: model.currentStreak.lastStudyDate,
        freezesRemaining: model.currentStreak.freezesRemaining,
        isCurrentlyFrozen: model.currentStreak.isCurrentlyFrozen,
        freezeExpiresAt: model.currentStreak.freezeExpiresAt,
      ),
      longestStreak: model.longestStreak,
      totalStreaks: model.totalStreaks,
      history: model.history.map((entry) => StreakHistoryEntryEntity(
        id: entry.id,
        streakLength: entry.streakLength,
        startDate: entry.startDate,
        endDate: entry.endDate,
        endReason: entry.endReason,
        freezesUsed: entry.freezesUsed,
        durationDays: entry.durationDays,
        isActive: entry.isActive,
      )).toList(),
      statistics: StreakStatisticsEntity(
        averageStreakLength: model.statistics.averageStreakLength,
        totalActiveDays: model.statistics.totalActiveDays,
        totalFreezesUsed: model.statistics.totalFreezesUsed,
        streakDistribution: model.statistics.streakDistribution,
      ),
      success: model.success,
      error: model.error,
    );
  }
}
