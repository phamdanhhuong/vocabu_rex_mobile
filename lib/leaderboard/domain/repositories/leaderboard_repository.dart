import 'package:vocabu_rex_mobile/leaderboard/domain/entities/leaderboard_entity.dart';
import 'package:vocabu_rex_mobile/leaderboard/domain/entities/user_tier_entity.dart';

abstract class LeaderboardRepository {
  Future<void> joinLeague();
  Future<LeaderboardEntity> getStandings();
  Future<UserTierEntity> getUserTier();
  Future<List<dynamic>> getHistory({int limit = 10});
}
