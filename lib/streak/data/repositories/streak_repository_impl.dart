import 'package:vocabu_rex_mobile/streak/domain/entities/get_streak_history_response_entity.dart';
import 'package:vocabu_rex_mobile/streak/domain/entities/current_streak_entity.dart';
import 'package:vocabu_rex_mobile/streak/domain/entities/streak_history_entry_entity.dart';
import 'package:vocabu_rex_mobile/streak/domain/entities/streak_statistics_entity.dart';
import 'package:vocabu_rex_mobile/streak/domain/repositories/streak_repository.dart';
import 'package:vocabu_rex_mobile/streak/domain/entities/use_streak_freeze_response_entity.dart';
import 'package:vocabu_rex_mobile/streak/domain/entities/get_streak_calendar_response_entity.dart';
import 'package:vocabu_rex_mobile/streak/domain/entities/calendar_day_entity.dart';
import 'package:vocabu_rex_mobile/streak/domain/entities/calendar_summary_entity.dart';
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
  
  @override
  Future<UseStreakFreezeResponseEntity> useStreakFreeze({String? reason}) async {
    final model = await remoteDataSource.useStreakFreeze(reason: reason);
    return UseStreakFreezeResponseEntity(
      userId: model.userId,
      freezesRemaining: model.freezesRemaining,
      freezeExpiresAt: model.freezeExpiresAt,
      currentStreak: model.currentStreak,
      freezeDurationHours: model.freezeDurationHours,
      success: model.success,
      error: model.error,
    );
  }

  @override
  Future<GetStreakCalendarResponseEntity> getStreakCalendar({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final model = await remoteDataSource.getStreakCalendar(
      startDate: startDate,
      endDate: endDate,
    );
    return GetStreakCalendarResponseEntity(
      userId: model.userId,
      startDate: DateTime.parse(model.startDate),
      endDate: DateTime.parse(model.endDate),
      days: model.days.map((day) => CalendarDayEntity(
        date: DateTime.parse(day.date),
        status: day.status,
        streakCount: day.streakCount,
        isStreakStart: day.isStreakStart,
        isStreakEnd: day.isStreakEnd,
        freezeUsed: day.freezeUsed,
      )).toList(),
      summary: CalendarSummaryEntity(
        totalDays: model.summary.totalDays,
        activeDays: model.summary.activeDays,
        frozenDays: model.summary.frozenDays,
        missedDays: model.summary.missedDays,
        currentStreak: model.summary.currentStreak,
        longestStreakInRange: model.summary.longestStreakInRange,
      ),
      success: model.success,
      error: model.error,
    );
  }
}
