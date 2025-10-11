import 'package:vocabu_rex_mobile/streak/data/datasources/streak_datasource.dart';
import 'package:vocabu_rex_mobile/streak/data/models/get_streak_history_response_model.dart';
import 'package:vocabu_rex_mobile/streak/data/services/streak_service.dart';

class StreakDataSourceImpl implements StreakDataSource {
  final StreakService streakService;
  StreakDataSourceImpl(this.streakService);

  @override
  Future<GetStreakHistoryResponseModel> getStreakHistory({int? limit, bool? includeCurrentStreak}) async {
    final res = await streakService.getStreakHistory(limit: limit, includeCurrentStreak: includeCurrentStreak);
    final result = GetStreakHistoryResponseModel.fromJson(res);
    return result;
  }
}
