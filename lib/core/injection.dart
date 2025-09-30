import 'package:get_it/get_it.dart';
import 'package:vocabu_rex_mobile/auth/data/datasources/auth_datasource.dart';
import 'package:vocabu_rex_mobile/auth/data/datasources/auth_datasource_impl.dart';
import 'package:vocabu_rex_mobile/auth/data/repositoriesImpl/auth_repository_impl.dart';
import 'package:vocabu_rex_mobile/auth/data/services/auth_service.dart';
import 'package:vocabu_rex_mobile/auth/domain/repositories/auth_repository.dart';
import 'package:vocabu_rex_mobile/auth/domain/usecases/login_usecase.dart';
import 'package:vocabu_rex_mobile/auth/domain/usecases/register_usecase.dart';
import 'package:vocabu_rex_mobile/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:vocabu_rex_mobile/auth/ui/blocs/auth_bloc.dart';
import 'package:vocabu_rex_mobile/home/data/datasources/home_datasource.dart';
import 'package:vocabu_rex_mobile/home/data/datasources/home_datasource_impl.dart';
import 'package:vocabu_rex_mobile/home/data/repositoriesImpl/home_repository_impl.dart';
import 'package:vocabu_rex_mobile/home/data/service/home_service.dart';
import 'package:vocabu_rex_mobile/home/domain/repositories/home_repository.dart';
import 'package:vocabu_rex_mobile/home/domain/usecases/get_user_profile_usecase.dart';
import 'package:vocabu_rex_mobile/home/ui/blocs/home_bloc.dart';

final sl = GetIt.instance;

void init() {
  // Service
  sl.registerLazySingleton<AuthService>(() => AuthService());
  sl.registerLazySingleton<HomeService>(() => HomeService());

  // DataSource
  sl.registerLazySingleton<AuthDataSource>(() => AuthDataSourceImpl(sl()));
  sl.registerLazySingleton<HomeDatasource>(() => HomeDatasourceImpl(sl()));

  // Repository (đăng ký theo interface, không phải Impl)
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(authDataSource: sl()),
  );
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(homeDatasource: sl()),
  );

  // UseCase
  sl.registerLazySingleton<RegisterUsecase>(
    () => RegisterUsecase(authRepository: sl()),
  );

  sl.registerLazySingleton<LoginUsecase>(
    () => LoginUsecase(authRepository: sl()),
  );

  sl.registerLazySingleton<GetUserProfileUsecase>(
    () => GetUserProfileUsecase(homeRepository: sl()),
  );

  sl.registerLazySingleton<VerifyOtpUsecase>(
    () => VerifyOtpUsecase(authRepository: sl()),
  );

  // Bloc
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      registerUsecase: sl(),
      loginUsecase: sl(),
      verifyOtpUsecase: sl(),
    ),
  );
  sl.registerFactory<HomeBloc>(() => HomeBloc(getUserProfileUsecase: sl()));
}
