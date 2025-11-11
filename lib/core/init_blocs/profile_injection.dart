import 'package:get_it/get_it.dart';
import 'package:vocabu_rex_mobile/profile/data/datasources/profile_datasource_impl.dart';
import 'package:vocabu_rex_mobile/profile/data/datasources/profile_datasource.dart';
import 'package:vocabu_rex_mobile/profile/data/repositories/profile_repository_impl.dart';
import 'package:vocabu_rex_mobile/profile/data/service/profile_service.dart';
import 'package:vocabu_rex_mobile/profile/domain/repositories/profile_repository.dart';
import 'package:vocabu_rex_mobile/profile/domain/usecases/get_profile_usecase.dart';
import 'package:vocabu_rex_mobile/profile/domain/usecases/follow_user_usecase.dart';
import 'package:vocabu_rex_mobile/profile/domain/usecases/unfollow_user_usecase.dart';
import 'package:vocabu_rex_mobile/profile/domain/usecases/get_achievements_usecase.dart';
import 'package:vocabu_rex_mobile/profile/ui/blocs/profile_bloc.dart';

final GetIt sl = GetIt.instance;

void initProfile() {
  // Service
  sl.registerLazySingleton<ProfileService>(() => ProfileService());

  // DataSource
  sl.registerLazySingleton<ProfileDataSource>(
    () => ProfileDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(profileDataSource: sl()),
  );

  // UseCase
  sl.registerLazySingleton<GetProfileUsecase>(
    () => GetProfileUsecase(repository: sl()),
  );

  sl.registerLazySingleton<FollowUserUsecase>(() => FollowUserUsecase(sl()));

  sl.registerLazySingleton<UnfollowUserUsecase>(
    () => UnfollowUserUsecase(sl()),
  );

  sl.registerLazySingleton<GetAchievementsUsecase>(
    () => GetAchievementsUsecase(sl()),
  );

  // Bloc
  sl.registerFactory<ProfileBloc>(
    () => ProfileBloc(
      getProfileUsecase: sl(),
      followUserUsecase: sl(),
      unfollowUserUsecase: sl(),
      getAchievementsUsecase: sl(),
    ),
  );
}
