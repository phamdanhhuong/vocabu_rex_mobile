import 'package:get_it/get_it.dart';
import 'package:vocabu_rex_mobile/minigame/data/repositories/minigame_repository_impl.dart';
import 'package:vocabu_rex_mobile/minigame/data/services/minigame_service.dart';
import 'package:vocabu_rex_mobile/minigame/domain/repositories/minigame_repository.dart';
import 'package:vocabu_rex_mobile/minigame/domain/usecases/get_minigame_status_usecase.dart';
import 'package:vocabu_rex_mobile/minigame/domain/usecases/get_minigame_usecase.dart';
import 'package:vocabu_rex_mobile/minigame/domain/usecases/submit_minigame_usecase.dart';
import 'package:vocabu_rex_mobile/minigame/ui/blocs/minigame_bloc.dart';

final GetIt sl = GetIt.instance;

void initMinigame() {
  // Service
  sl.registerLazySingleton<MiniGameService>(() => MiniGameService());

  // Repository
  sl.registerLazySingleton<MiniGameRepository>(
    () => MiniGameRepositoryImpl(sl()),
  );

  // Use cases
  sl.registerLazySingleton<GetMiniGameUseCase>(
    () => GetMiniGameUseCase(sl()),
  );
  sl.registerLazySingleton<SubmitMiniGameUseCase>(
    () => SubmitMiniGameUseCase(sl()),
  );
  sl.registerLazySingleton<GetMiniGameStatusUseCase>(
    () => GetMiniGameStatusUseCase(sl()),
  );

  // Bloc — factory vì mỗi lần mở minigame cần instance mới
  sl.registerFactory<MiniGameBloc>(
    () => MiniGameBloc(
      getMiniGameUseCase: sl(),
      submitMiniGameUseCase: sl(),
      getMiniGameStatusUseCase: sl(),
    ),
  );
}
