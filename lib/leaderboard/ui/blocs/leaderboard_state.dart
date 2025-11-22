import 'package:vocabu_rex_mobile/leaderboard/domain/entities/leaderboard_entity.dart';
import 'package:vocabu_rex_mobile/leaderboard/domain/entities/user_tier_entity.dart';

abstract class LeaderboardState {}

class LeaderboardInitial extends LeaderboardState {}

class LeaderboardLoading extends LeaderboardState {}

class LeaderboardLoaded extends LeaderboardState {
  final LeaderboardEntity leaderboard;
  final UserTierEntity userTier;

  LeaderboardLoaded({
    required this.leaderboard,
    required this.userTier,
  });
}

class LeaderboardError extends LeaderboardState {
  final String message;

  LeaderboardError(this.message);
}
