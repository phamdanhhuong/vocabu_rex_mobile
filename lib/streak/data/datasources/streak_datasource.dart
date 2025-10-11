import '../models/get_streak_history_response_model.dart';

abstract class StreakDataSource {
  Future<GetStreakHistoryResponseModel> getStreakHistory({int? limit, bool? includeCurrentStreak});
}
