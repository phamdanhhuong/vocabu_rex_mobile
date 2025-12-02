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
import 'package:vocabu_rex_mobile/profile/domain/usecases/get_public_profile_usecase.dart';
import 'package:vocabu_rex_mobile/profile/domain/usecases/report_user_usecase.dart';
import 'package:vocabu_rex_mobile/profile/domain/usecases/block_user_usecase.dart';
import 'package:vocabu_rex_mobile/profile/domain/usecases/unblock_user_usecase.dart';
import 'package:vocabu_rex_mobile/profile/ui/blocs/profile_bloc.dart';
import 'package:vocabu_rex_mobile/profile/ui/blocs/public_profile_bloc.dart';

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

  // Public Profile Use Cases
  sl.registerLazySingleton<GetPublicProfileUsecase>(
    () => GetPublicProfileUsecase(sl()),
  );

  sl.registerLazySingleton<ReportUserUsecase>(
    () => ReportUserUsecase(sl()),
  );

  sl.registerLazySingleton<BlockUserUsecase>(
    () => BlockUserUsecase(sl()),
  );

  sl.registerLazySingleton<UnblockUserUsecase>(
    () => UnblockUserUsecase(sl()),
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

  sl.registerFactory<PublicProfileBloc>(
    () => PublicProfileBloc(
      getPublicProfileUsecase: sl(),
      followUserUsecase: sl(),
      unfollowUserUsecase: sl(),
      reportUserUsecase: sl(),
      blockUserUsecase: sl(),
    ),
  );
}
