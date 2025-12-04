import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/leaderboard/domain/repositories/leaderboard_repository.dart';
import 'package:vocabu_rex_mobile/leaderboard/ui/blocs/leaderboard_event.dart';
import 'package:vocabu_rex_mobile/leaderboard/ui/blocs/leaderboard_state.dart';

class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  final LeaderboardRepository repository;

  LeaderboardBloc(this.repository) : super(LeaderboardInitial()) {
    on<LoadLeaderboardEvent>(_onLoadLeaderboard);
    on<RefreshLeaderboardEvent>(_onRefreshLeaderboard);
    on<JoinLeagueEvent>(_onJoinLeague);
  }

  Future<void> _onLoadLeaderboard(
      LoadLeaderboardEvent event, Emitter<LeaderboardState> emit) async {
    emit(LeaderboardLoading());
    try {
      final leaderboard = await repository.getStandings();
      final userTier = await repository.getUserTier();
      emit(LeaderboardLoaded(leaderboard: leaderboard, userTier: userTier));
    } catch (e) {
      final errorMessage = e.toString().toLowerCase();
      // Check if error is related to not being in a league or not enough exercises completed
      if (errorMessage.contains('not in any league') || 
          errorMessage.contains('not eligible') || 
          errorMessage.contains('chưa đủ điều kiện') ||
          errorMessage.contains('complete at least') ||
          errorMessage.contains('ít nhất')) {
        emit(LeaderboardNotEligible());
      } else {
        emit(LeaderboardError(e.toString()));
      }
    }
  }

  Future<void> _onRefreshLeaderboard(
      RefreshLeaderboardEvent event, Emitter<LeaderboardState> emit) async {
    try {
      final leaderboard = await repository.getStandings();
      final userTier = await repository.getUserTier();
      emit(LeaderboardLoaded(leaderboard: leaderboard, userTier: userTier));
    } catch (e) {
      emit(LeaderboardError(e.toString()));
    }
  }

  Future<void> _onJoinLeague(
      JoinLeagueEvent event, Emitter<LeaderboardState> emit) async {
    try {
      await repository.joinLeague();
      add(LoadLeaderboardEvent());
    } catch (e) {
      emit(LeaderboardError(e.toString()));
    }
  }
}
