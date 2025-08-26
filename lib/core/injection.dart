import 'package:get_it/get_it.dart';
import 'package:vocabu_rex_mobile/auth/data/datasources/auth_datasource.dart';
import 'package:vocabu_rex_mobile/auth/data/datasources/auth_datasource_impl.dart';
import 'package:vocabu_rex_mobile/auth/data/repositoriesImpl/auth_repository_impl.dart';
import 'package:vocabu_rex_mobile/auth/data/services/auth_service.dart';
import 'package:vocabu_rex_mobile/auth/domain/repositories/auth_repository.dart';
import 'package:vocabu_rex_mobile/auth/domain/usecases/login_usecase.dart';
import 'package:vocabu_rex_mobile/auth/domain/usecases/register_usecase.dart';
import 'package:vocabu_rex_mobile/auth/ui/blocs/auth_bloc.dart';

final sl = GetIt.instance;

void init() {
  // Service
  sl.registerLazySingleton<AuthService>(() => AuthService());

  // DataSource
  sl.registerLazySingleton<AuthDataSource>(() => AuthDataSourceImpl(sl()));

  // Repository (đăng ký theo interface, không phải Impl)
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(authDataSource: sl()),
  );

  // UseCase
  sl.registerLazySingleton<RegisterUsecase>(
    () => RegisterUsecase(authRepository: sl()),
  );

  sl.registerLazySingleton<LoginUsecase>(
    () => LoginUsecase(authRepository: sl()),
  );

  // Bloc
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(registerUsecase: sl(), loginUsecase: sl()),
  );
}
