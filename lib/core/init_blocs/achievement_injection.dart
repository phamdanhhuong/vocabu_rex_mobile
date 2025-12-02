import 'package:get_it/get_it.dart';
import 'package:vocabu_rex_mobile/achievement/data/datasources/achievement_datasource.dart';
import 'package:vocabu_rex_mobile/achievement/data/datasources/achievement_datasource_impl.dart';
import 'package:vocabu_rex_mobile/achievement/data/repositories/achievement_repository_impl.dart';
import 'package:vocabu_rex_mobile/achievement/data/service/achievement_service.dart';
import 'package:vocabu_rex_mobile/achievement/domain/repositories/achievement_repository.dart';
import 'package:vocabu_rex_mobile/achievement/domain/usecases/get_achievements_by_category_usecase.dart';
import 'package:vocabu_rex_mobile/achievement/domain/usecases/get_achievements_usecase.dart';
import 'package:vocabu_rex_mobile/achievement/domain/usecases/get_recent_achievements_usecase.dart';
import 'package:vocabu_rex_mobile/achievement/domain/usecases/get_achievements_summary_usecase.dart';
import 'package:vocabu_rex_mobile/achievement/ui/blocs/achievement_bloc.dart';

final GetIt sl = GetIt.instance;

void initAchievement() {
  // Services (lowest level)
  sl.registerLazySingleton(() => AchievementService());

  // Data sources
  sl.registerLazySingleton<AchievementDataSource>(
    () => AchievementDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<AchievementRepository>(
    () => AchievementRepositoryImpl(sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetAchievementsUsecase(sl()));
  sl.registerLazySingleton(() => GetAchievementsByCategoryUsecase(sl()));
  sl.registerLazySingleton(() => GetRecentAchievementsUsecase(sl()));
  sl.registerLazySingleton(() => GetAchievementsSummaryUsecase(sl()));

  // Bloc (highest level)
  sl.registerFactory(
    () => AchievementBloc(
      getAchievementsUsecase: sl(),
      getAchievementsByCategoryUsecase: sl(),
      getRecentAchievementsUsecase: sl(),
      getAchievementsSummaryUsecase: sl(),
    ),
  );
}
