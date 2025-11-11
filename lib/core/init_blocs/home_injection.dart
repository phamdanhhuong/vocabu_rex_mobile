import 'package:get_it/get_it.dart';
import 'package:vocabu_rex_mobile/home/data/datasources/home_datasource.dart';
import 'package:vocabu_rex_mobile/home/data/datasources/home_datasource_impl.dart';
import 'package:vocabu_rex_mobile/home/data/repositoriesImpl/home_repository_impl.dart';
import 'package:vocabu_rex_mobile/home/data/service/home_service.dart';
import 'package:vocabu_rex_mobile/home/domain/repositories/home_repository.dart';
import 'package:vocabu_rex_mobile/home/domain/usecases/get_skill_by_id_usecase.dart';
import 'package:vocabu_rex_mobile/home/domain/usecases/get_user_progress_usecase.dart';
import 'package:vocabu_rex_mobile/home/ui/blocs/home_bloc.dart';

final GetIt sl = GetIt.instance;

void initHome() {
  // Service
  sl.registerLazySingleton<HomeService>(() => HomeService());

  // DataSource
  sl.registerLazySingleton<HomeDatasource>(() => HomeDatasourceImpl(sl()));

  // Repository
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(homeDatasource: sl()),
  );

  // UseCase
  sl.registerLazySingleton<GetUserProgressUsecase>(
    () => GetUserProgressUsecase(homeRepository: sl()),
  );

  sl.registerLazySingleton<GetSkillByIdUsecase>(
    () => GetSkillByIdUsecase(homeRepository: sl()),
  );

  // Bloc
  sl.registerFactory<HomeBloc>(
    () => HomeBloc(getUserProgressUsecase: sl(), getSkillByIdUsecase: sl()),
  );
}
