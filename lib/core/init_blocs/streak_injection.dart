import 'package:get_it/get_it.dart';
import 'package:vocabu_rex_mobile/streak/data/datasources/streak_datasource.dart';
import 'package:vocabu_rex_mobile/streak/data/datasources/streak_datasource_impl.dart';
import 'package:vocabu_rex_mobile/streak/data/repositories/streak_repository_impl.dart';
import 'package:vocabu_rex_mobile/streak/data/services/streak_service.dart';
import 'package:vocabu_rex_mobile/streak/domain/repositories/streak_repository.dart';
import 'package:vocabu_rex_mobile/streak/domain/usecases/get_streak_history_usecase.dart';
import 'package:vocabu_rex_mobile/streak/domain/usecases/get_streak_calendar_usecase.dart';
import 'package:vocabu_rex_mobile/streak/ui/blocs/streak_bloc.dart';
import 'package:vocabu_rex_mobile/streak/domain/usecases/use_streak_freeze_usecase.dart';

final GetIt sl = GetIt.instance;

void initStreak() {
  // Service
  sl.registerLazySingleton<StreakService>(() => StreakService());

  // DataSource
  sl.registerLazySingleton<StreakDataSource>(() => StreakDataSourceImpl(sl()));

  // Repository
  sl.registerLazySingleton<StreakRepository>(
    () => StreakRepositoryImpl(remoteDataSource: sl()),
  );

  // UseCase
  sl.registerLazySingleton<GetStreakHistoryUseCase>(
    () => GetStreakHistoryUseCase(repository: sl()),
  );

  sl.registerLazySingleton<UseStreakFreezeUseCase>(
    () => UseStreakFreezeUseCase(repository: sl()),
  );

  sl.registerLazySingleton<GetStreakCalendarUseCase>(
    () => GetStreakCalendarUseCase(sl()),
  );

  // Bloc
  sl.registerFactory<StreakBloc>(
    () => StreakBloc(
      getStreakHistoryUseCase: sl(),
      useStreakFreezeUseCase: sl(),
      getStreakCalendarUseCase: sl(),
    ),
  );
}
