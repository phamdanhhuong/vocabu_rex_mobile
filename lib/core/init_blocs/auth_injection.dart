import 'package:get_it/get_it.dart';
import 'package:vocabu_rex_mobile/auth/data/datasources/auth_datasource.dart';
import 'package:vocabu_rex_mobile/auth/data/datasources/auth_datasource_impl.dart';
import 'package:vocabu_rex_mobile/auth/data/repositoriesImpl/auth_repository_impl.dart';
import 'package:vocabu_rex_mobile/auth/data/services/auth_service.dart';
import 'package:vocabu_rex_mobile/auth/domain/repositories/auth_repository.dart';
import 'package:vocabu_rex_mobile/auth/domain/usecases/login_usecase.dart';
import 'package:vocabu_rex_mobile/auth/domain/usecases/google_login_usecase.dart';
import 'package:vocabu_rex_mobile/auth/domain/usecases/facebook_login_usecase.dart';
import 'package:vocabu_rex_mobile/auth/domain/usecases/biometric_login_usecase.dart';
import 'package:vocabu_rex_mobile/auth/domain/usecases/register_usecase.dart';
import 'package:vocabu_rex_mobile/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:vocabu_rex_mobile/auth/ui/blocs/auth_bloc.dart';

final GetIt sl = GetIt.instance;

void initAuth() {
  // Service
  sl.registerLazySingleton<AuthService>(() => AuthService());

  // DataSource
  sl.registerLazySingleton<AuthDataSource>(() => AuthDataSourceImpl(sl()));

  // Repository
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

  sl.registerLazySingleton<GoogleLoginUsecase>(
    () => GoogleLoginUsecase(authRepository: sl()),
  );

  sl.registerLazySingleton<FacebookLoginUsecase>(
    () => FacebookLoginUsecase(authRepository: sl()),
  );

  sl.registerLazySingleton<BiometricLoginUsecase>(
    () => BiometricLoginUsecase(authRepository: sl()),
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
      googleLoginUsecase: sl(),
      facebookLoginUsecase: sl(),
      biometricLoginUsecase: sl(),
    ),
  );
}
