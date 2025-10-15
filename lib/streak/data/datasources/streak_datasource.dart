import '../models/get_streak_history_response_model.dart';
import '../models/use_streak_freeze_response_model.dart';

abstract class StreakDataSource {
  Future<GetStreakHistoryResponseModel> getStreakHistory({int? limit, bool? includeCurrentStreak});

  Future<UseStreakFreezeResponseModel> useStreakFreeze({String? reason});
}
