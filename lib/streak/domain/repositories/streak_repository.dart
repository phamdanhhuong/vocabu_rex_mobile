import '../entities/get_streak_history_response_entity.dart';

abstract class StreakRepository {
  Future<GetStreakHistoryResponseEntity> getStreakHistory({
    int? limit,
    bool? includeCurrentStreak,
  });
}
