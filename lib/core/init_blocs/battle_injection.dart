import 'package:get_it/get_it.dart';
import 'package:vocabu_rex_mobile/battle/data/services/battle_api_service.dart';
import 'package:vocabu_rex_mobile/battle/data/services/battle_socket_service.dart';
import 'package:vocabu_rex_mobile/battle/ui/blocs/battle_bloc.dart';

final GetIt sl = GetIt.instance;

void initBattle() {
  // Services
  sl.registerLazySingleton<BattleSocketService>(() => BattleSocketService());
  sl.registerLazySingleton<BattleApiService>(() => BattleApiService());

  // Bloc
  sl.registerLazySingleton<BattleBloc>(
    () => BattleBloc(
      apiService: sl<BattleApiService>(),
      socketService: sl<BattleSocketService>(),
    ),
  );
}
