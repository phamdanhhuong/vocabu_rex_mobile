import 'package:get_it/get_it.dart';
import 'package:vocabu_rex_mobile/leaderboard/data/services/leaderboard_service.dart';
import 'package:vocabu_rex_mobile/leaderboard/data/repositories/leaderboard_repository_impl.dart';
import 'package:vocabu_rex_mobile/leaderboard/ui/blocs/leaderboard_bloc.dart';

final GetIt sl = GetIt.instance;

void initLeaderboard() {
  // Service
  sl.registerLazySingleton<LeaderboardService>(() => LeaderboardService());

  // Repository
  sl.registerLazySingleton<LeaderboardRepositoryImpl>(
    () => LeaderboardRepositoryImpl(sl()),
  );

  // Bloc
  sl.registerFactory<LeaderboardBloc>(
    () => LeaderboardBloc(sl()),
  );
}
