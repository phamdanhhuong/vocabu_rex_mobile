import 'package:vocabu_rex_mobile/leaderboard/data/services/leaderboard_service.dart';
import 'package:vocabu_rex_mobile/leaderboard/domain/entities/leaderboard_entity.dart';
import 'package:vocabu_rex_mobile/leaderboard/domain/entities/user_tier_entity.dart';
import 'package:vocabu_rex_mobile/leaderboard/domain/repositories/leaderboard_repository.dart';

class LeaderboardRepositoryImpl implements LeaderboardRepository {
  final LeaderboardService _service;

  LeaderboardRepositoryImpl(this._service);

  @override
  Future<void> joinLeague() async {
    await _service.joinLeague();
  }

  @override
  Future<LeaderboardEntity> getStandings() async {
    final data = await _service.getStandings();
    return LeaderboardEntity.fromJson(data);
  }

  @override
  Future<UserTierEntity> getUserTier() async {
    final data = await _service.getUserTier();
    return UserTierEntity.fromJson(data);
  }

  @override
  Future<List<dynamic>> getHistory({int limit = 10}) async {
    return await _service.getHistory(limit: limit);
  }
}
