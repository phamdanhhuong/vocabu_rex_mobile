import 'package:get_it/get_it.dart';
import 'package:vocabu_rex_mobile/currency/data/datasources/currency_datasource.dart';
import 'package:vocabu_rex_mobile/currency/data/datasources/currency_datasource_impl.dart';
import 'package:vocabu_rex_mobile/currency/data/repositories/currency_repository_impl.dart';
import 'package:vocabu_rex_mobile/currency/data/services/currency_service.dart';
import 'package:vocabu_rex_mobile/currency/domain/usecases/get_currency_balance_usecase.dart';
import 'package:vocabu_rex_mobile/currency/ui/blocs/currency_bloc.dart';
import 'package:vocabu_rex_mobile/profile/data/datasources/profile_datasource_impl.dart';
import 'package:vocabu_rex_mobile/profile/data/datasources/profile_datasource.dart';
import 'package:vocabu_rex_mobile/profile/data/repositories/profile_repository_impl.dart';
import 'package:vocabu_rex_mobile/profile/data/service/profile_service.dart';
import 'package:vocabu_rex_mobile/profile/domain/repositories/profile_repository.dart';
import 'package:vocabu_rex_mobile/profile/ui/blocs/profile_bloc.dart';
import 'package:vocabu_rex_mobile/auth/data/datasources/auth_datasource.dart';
import 'package:vocabu_rex_mobile/auth/data/datasources/auth_datasource_impl.dart';
import 'package:vocabu_rex_mobile/auth/data/repositoriesImpl/auth_repository_impl.dart';
import 'package:vocabu_rex_mobile/auth/data/services/auth_service.dart';
import 'package:vocabu_rex_mobile/auth/domain/repositories/auth_repository.dart';
import 'package:vocabu_rex_mobile/auth/domain/usecases/login_usecase.dart';
import 'package:vocabu_rex_mobile/auth/domain/usecases/register_usecase.dart';
import 'package:vocabu_rex_mobile/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:vocabu_rex_mobile/auth/ui/blocs/auth_bloc.dart';
import 'package:vocabu_rex_mobile/exercise/data/datasources/exercise_datasource.dart';
import 'package:vocabu_rex_mobile/exercise/data/datasources/exercise_datasource_impl.dart';
import 'package:vocabu_rex_mobile/exercise/data/repositoriesImpl/exercise_repository_impl.dart';
import 'package:vocabu_rex_mobile/exercise/data/services/exercise_service.dart';
import 'package:vocabu_rex_mobile/exercise/domain/repositories/exercise_repository.dart';
import 'package:vocabu_rex_mobile/exercise/domain/usecases/get_exercise_usecase.dart';
import 'package:vocabu_rex_mobile/exercise/domain/usecases/submit_lesson_usecase.dart';
import 'package:vocabu_rex_mobile/exercise/ui/blocs/exercise_bloc.dart';
import 'package:vocabu_rex_mobile/home/data/datasources/home_datasource.dart';
import 'package:vocabu_rex_mobile/home/data/datasources/home_datasource_impl.dart';
import 'package:vocabu_rex_mobile/home/data/repositoriesImpl/home_repository_impl.dart';
import 'package:vocabu_rex_mobile/home/data/service/home_service.dart';
import 'package:vocabu_rex_mobile/home/domain/repositories/home_repository.dart';
import 'package:vocabu_rex_mobile/home/domain/usecases/get_skill_by_id_usecase.dart';
import 'package:vocabu_rex_mobile/home/domain/usecases/get_user_progress_usecase.dart';
import 'package:vocabu_rex_mobile/profile/domain/usecases/get_profile_usecase.dart';
import 'package:vocabu_rex_mobile/home/ui/blocs/home_bloc.dart';

final sl = GetIt.instance;

void init() {
  // Service
  sl.registerLazySingleton<AuthService>(() => AuthService());
  sl.registerLazySingleton<HomeService>(() => HomeService());
  sl.registerLazySingleton<ExerciseService>(() => ExerciseService());
  sl.registerLazySingleton<ProfileService>(() => ProfileService());
  sl.registerLazySingleton<CurrencyService>(() => CurrencyService());

  // DataSource
  sl.registerLazySingleton<AuthDataSource>(() => AuthDataSourceImpl(sl()));
  sl.registerLazySingleton<HomeDatasource>(() => HomeDatasourceImpl(sl()));
  sl.registerLazySingleton<ExerciseDataSource>(
    () => ExerciseDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ProfileDataSource>(
    () => ProfileDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<CurrencyDataSource>(
    () => CurrencyDataSourceImpl(sl()),
  );

  // Repository (đăng ký theo interface, không phải Impl)
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(authDataSource: sl()),
  );
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(homeDatasource: sl()),
  );
  sl.registerLazySingleton<ExerciseRepository>(
    () => ExcerciseRepositoryImpl(exerciseDataSource: sl()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(profileDataSource: sl()),
  );
  sl.registerLazySingleton<CurrencyRepository>(
    () => CurrencyRepositoryImpl(remoteDataSource: sl()),
  );
  // UseCase
  sl.registerLazySingleton<RegisterUsecase>(
    () => RegisterUsecase(authRepository: sl()),
  );

  sl.registerLazySingleton<LoginUsecase>(
    () => LoginUsecase(authRepository: sl()),
  );

  sl.registerLazySingleton<GetUserProgressUsecase>(
    () => GetUserProgressUsecase(homeRepository: sl()),
  );

  sl.registerLazySingleton<GetSkillByIdUsecase>(
    () => GetSkillByIdUsecase(homeRepository: sl()),
  );

  sl.registerLazySingleton<VerifyOtpUsecase>(
    () => VerifyOtpUsecase(authRepository: sl()),
  );

  sl.registerLazySingleton<GetExerciseUseCase>(
    () => GetExerciseUseCase(repository: sl()),
  );

  sl.registerLazySingleton<SubmitLessonUsecase>(
    () => SubmitLessonUsecase(repository: sl()),
  );

  sl.registerLazySingleton<GetProfileUsecase>(
    () => GetProfileUsecase(repository: sl()),
  );
  
  sl.registerLazySingleton<GetCurrencyBalanceUseCase>(
    () => GetCurrencyBalanceUseCase(repository: sl()),
  );
  // Bloc
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      registerUsecase: sl(),
      loginUsecase: sl(),
      verifyOtpUsecase: sl(),
    ),
  );
  sl.registerFactory<HomeBloc>(
    () => HomeBloc(
      getUserProgressUsecase: sl(),
      getSkillByIdUsecase: sl(),
    ),
  );

  sl.registerFactory<ExerciseBloc>(
    () => ExerciseBloc(getExerciseUseCase: sl(), submitLessonUsecase: sl()),
  );
  
  sl.registerFactory<ProfileBloc>(
    () => ProfileBloc(getProfileUsecase: sl()),
  );

  
  sl.registerFactory<CurrencyBloc>(
    () => CurrencyBloc(getCurrencyBalanceUseCase: sl()),
  );
}
