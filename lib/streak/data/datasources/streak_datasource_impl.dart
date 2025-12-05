import 'package:vocabu_rex_mobile/streak/data/datasources/streak_datasource.dart';
import 'package:vocabu_rex_mobile/streak/data/models/get_streak_history_response_model.dart';
import 'package:vocabu_rex_mobile/streak/data/services/streak_service.dart';
import 'package:vocabu_rex_mobile/streak/data/models/use_streak_freeze_response_model.dart';
import 'package:vocabu_rex_mobile/streak/data/models/get_streak_calendar_response_model.dart';

class StreakDataSourceImpl implements StreakDataSource {
  final StreakService streakService;
  StreakDataSourceImpl(this.streakService);

  @override
  Future<GetStreakHistoryResponseModel> getStreakHistory({int? limit, bool? includeCurrentStreak}) async {
    final res = await streakService.getStreakHistory(limit: limit, includeCurrentStreak: includeCurrentStreak);
    final result = GetStreakHistoryResponseModel.fromJson(res);
    return result;
  }

  @override
  Future<UseStreakFreezeResponseModel> useStreakFreeze({String? reason}) async {
    final res = await streakService.useStreakFreeze(reason: reason);
    return UseStreakFreezeResponseModel.fromJson(res);
  }

  @override
  Future<GetStreakCalendarResponseModel> getStreakCalendar({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final res = await streakService.getStreakCalendar(
      startDate: startDate,
      endDate: endDate,
    );
    return GetStreakCalendarResponseModel.fromJson(res);
  }
}
