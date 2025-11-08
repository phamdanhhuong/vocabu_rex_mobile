import 'package:get_it/get_it.dart';
import 'package:vocabu_rex_mobile/assistant/data/datasources/chat_datasource.dart';
import 'package:vocabu_rex_mobile/assistant/data/datasources/chat_datasource_impl.dart';
import 'package:vocabu_rex_mobile/assistant/data/repositoriesImpl/assistant_repository_impl.dart';
import 'package:vocabu_rex_mobile/assistant/data/services/assistant_service.dart';
import 'package:vocabu_rex_mobile/assistant/domain/repositories/assistant_repository.dart';
import 'package:vocabu_rex_mobile/assistant/domain/usecases/chat_usecase.dart';
import 'package:vocabu_rex_mobile/assistant/domain/usecases/start_chat_usecase.dart';
import 'package:vocabu_rex_mobile/assistant/ui/blocs/chat_bloc.dart';
import 'package:vocabu_rex_mobile/currency/data/datasources/currency_datasource.dart';
import 'package:vocabu_rex_mobile/currency/data/datasources/currency_datasource_impl.dart';
import 'package:vocabu_rex_mobile/currency/data/repositories/currency_repository_impl.dart';
import 'package:vocabu_rex_mobile/currency/data/services/currency_service.dart';
import 'package:vocabu_rex_mobile/currency/domain/usecases/get_currency_balance_usecase.dart';
import 'package:vocabu_rex_mobile/currency/ui/blocs/currency_bloc.dart';
import 'package:vocabu_rex_mobile/exercise/domain/usecases/get_image_description_score.dart';
import 'package:vocabu_rex_mobile/exercise/domain/usecases/get_review_exercise_usecase.dart';
import 'package:vocabu_rex_mobile/exercise/domain/usecases/get_speak_point.dart';
import 'package:vocabu_rex_mobile/friend/data/datasources/friend_datasource.dart';
import 'package:vocabu_rex_mobile/friend/data/datasources/friend_datasource_impl.dart';
import 'package:vocabu_rex_mobile/friend/data/repositories/friend_repository_impl.dart';
import 'package:vocabu_rex_mobile/friend/data/services/friend_service.dart';
import 'package:vocabu_rex_mobile/friend/domain/repositories/friend_repository.dart';
import 'package:vocabu_rex_mobile/friend/domain/usecases/follow_user_usecase.dart' as friend_follow;
import 'package:vocabu_rex_mobile/friend/domain/usecases/get_suggested_friends_usecase.dart';
import 'package:vocabu_rex_mobile/friend/domain/usecases/search_users_usecase.dart';
import 'package:vocabu_rex_mobile/friend/domain/usecases/unfollow_user_usecase.dart' as friend_unfollow;
import 'package:vocabu_rex_mobile/friend/ui/blocs/friend_bloc.dart';
import 'package:vocabu_rex_mobile/energy/data/datasources/energy_datasource.dart';
import 'package:vocabu_rex_mobile/energy/data/datasources/energy_datasource_impl.dart';
import 'package:vocabu_rex_mobile/energy/data/repositories/energy_repository_impl.dart';
import 'package:vocabu_rex_mobile/energy/data/services/energy_service.dart';
import 'package:vocabu_rex_mobile/energy/domain/repositories/energy_repository.dart';
import 'package:vocabu_rex_mobile/energy/domain/usecases/get_energy_status_usecase.dart';
import 'package:vocabu_rex_mobile/energy/domain/usecases/buy_energy_usecase.dart';
import 'package:vocabu_rex_mobile/energy/ui/blocs/energy_bloc.dart';
import 'package:vocabu_rex_mobile/streak/data/datasources/streak_datasource.dart';
import 'package:vocabu_rex_mobile/streak/data/datasources/streak_datasource_impl.dart';
import 'package:vocabu_rex_mobile/streak/data/repositories/streak_repository_impl.dart';
import 'package:vocabu_rex_mobile/streak/data/services/streak_service.dart';
import 'package:vocabu_rex_mobile/streak/domain/repositories/streak_repository.dart';
import 'package:vocabu_rex_mobile/streak/domain/usecases/get_streak_history_usecase.dart';
import 'package:vocabu_rex_mobile/streak/ui/blocs/streak_bloc.dart';
import 'package:vocabu_rex_mobile/streak/domain/usecases/use_streak_freeze_usecase.dart';
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
import 'package:vocabu_rex_mobile/exercise/data/datasources/exercise_datasource.dart';
import 'package:vocabu_rex_mobile/exercise/data/datasources/exercise_datasource_impl.dart';
import 'package:vocabu_rex_mobile/exercise/data/repositoriesImpl/exercise_repository_impl.dart';
import 'package:vocabu_rex_mobile/exercise/data/services/exercise_service.dart';
import 'package:vocabu_rex_mobile/exercise/domain/repositories/exercise_repository.dart';
import 'package:vocabu_rex_mobile/exercise/domain/usecases/get_exercise_usecase.dart';
import 'package:vocabu_rex_mobile/exercise/domain/usecases/submit_lesson_usecase.dart';
import 'package:vocabu_rex_mobile/energy/domain/usecases/consume_energy_usecase.dart';
import 'package:vocabu_rex_mobile/exercise/ui/blocs/exercise_bloc.dart';
import 'package:vocabu_rex_mobile/home/data/datasources/home_datasource.dart';
import 'package:vocabu_rex_mobile/home/data/datasources/home_datasource_impl.dart';
import 'package:vocabu_rex_mobile/home/data/repositoriesImpl/home_repository_impl.dart';
import 'package:vocabu_rex_mobile/home/data/service/home_service.dart';
import 'package:vocabu_rex_mobile/home/domain/repositories/home_repository.dart';
import 'package:vocabu_rex_mobile/home/domain/usecases/get_skill_by_id_usecase.dart';
import 'package:vocabu_rex_mobile/home/domain/usecases/get_user_progress_usecase.dart';
import 'package:vocabu_rex_mobile/home/ui/blocs/home_bloc.dart';

final sl = GetIt.instance;

void init() {
  // ENERGY
  sl.registerLazySingleton<EnergyService>(() => EnergyService());
  sl.registerLazySingleton<EnergyDatasource>(() => EnergyDatasourceImpl(sl()));
  sl.registerLazySingleton<EnergyRepository>(
    () => EnergyRepositoryImpl(datasource: sl()),
  );
  sl.registerLazySingleton<GetEnergyStatusUseCase>(
    () => GetEnergyStatusUseCase(repository: sl()),
  );
  sl.registerLazySingleton<BuyEnergyUseCase>(
    () => BuyEnergyUseCase(repository: sl()),
  );
  // Bloc
  // EnergyBloc is used across the app and sometimes accessed via sl<EnergyBloc>()
  // (for example from ExerciseBloc) — register it as a singleton so all callers
  // get the same instance that is provided to the widget tree in main.dart.
  sl.registerLazySingleton<EnergyBloc>(
    () => EnergyBloc(getEnergyStatusUseCase: sl(), buyEnergyUseCase: sl()),
  );
  sl.registerLazySingleton<StreakService>(() => StreakService());
  sl.registerLazySingleton<StreakDataSource>(() => StreakDataSourceImpl(sl()));
  sl.registerLazySingleton<StreakRepository>(
    () => StreakRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<GetStreakHistoryUseCase>(
    () => GetStreakHistoryUseCase(repository: sl()),
  );
  sl.registerLazySingleton<UseStreakFreezeUseCase>(
    () => UseStreakFreezeUseCase(repository: sl()),
  );
  sl.registerFactory<StreakBloc>(
    () =>
        StreakBloc(getStreakHistoryUseCase: sl(), useStreakFreezeUseCase: sl()),
  );
  // Service
  sl.registerLazySingleton<AuthService>(() => AuthService());
  sl.registerLazySingleton<HomeService>(() => HomeService());
  sl.registerLazySingleton<ExerciseService>(() => ExerciseService());
  sl.registerLazySingleton<ProfileService>(() => ProfileService());
  sl.registerLazySingleton<CurrencyService>(() => CurrencyService());
  sl.registerLazySingleton<AssistantService>(() => AssistantService());
  sl.registerLazySingleton<FriendService>(() => FriendService());

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
  sl.registerLazySingleton<ChatDatasource>(
    () => ChatDatasourceImpl(assistantService: sl()),
  );
  sl.registerLazySingleton<FriendDataSource>(
    () => FriendDataSourceImpl(sl()),
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
  sl.registerLazySingleton<AssistantRepository>(
    () => AssistantRepositoryImpl(datasource: sl()),
  );
  sl.registerLazySingleton<FriendRepository>(
    () => FriendRepositoryImpl(friendDataSource: sl()),
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

  sl.registerLazySingleton<GetReviewExerciseUsecase>(
    () => GetReviewExerciseUsecase(repository: sl()),
  );

  sl.registerLazySingleton<SubmitLessonUsecase>(
    () => SubmitLessonUsecase(repository: sl()),
  );

  // Consume energy usecase (for per-exercise deductions)
  sl.registerLazySingleton<ConsumeEnergyUseCase>(
    () => ConsumeEnergyUseCase(repository: sl()),
  );

  sl.registerLazySingleton<GetProfileUsecase>(
    () => GetProfileUsecase(repository: sl()),
  );

  sl.registerLazySingleton<FollowUserUsecase>(
    () => FollowUserUsecase(sl()),
  );

  sl.registerLazySingleton<UnfollowUserUsecase>(
    () => UnfollowUserUsecase(sl()),
  );

  sl.registerLazySingleton<GetAchievementsUsecase>(
    () => GetAchievementsUsecase(sl()),
  );

  sl.registerLazySingleton<GetSpeakPoint>(
    () => GetSpeakPoint(repository: sl()),
  );

  sl.registerLazySingleton<GetCurrencyBalanceUseCase>(
    () => GetCurrencyBalanceUseCase(repository: sl()),
  );

  sl.registerLazySingleton<StartChatUsecase>(
    () => StartChatUsecase(repository: sl()),
  );

  sl.registerLazySingleton<GetImageDescriptionScore>(
    () => GetImageDescriptionScore(repository: sl()),
  );

  sl.registerLazySingleton<ChatUsecase>(() => ChatUsecase(repository: sl()));

  sl.registerLazySingleton<SearchUsersUsecase>(
    () => SearchUsersUsecase(repository: sl()),
  );

  sl.registerLazySingleton<GetSuggestedFriendsUsecase>(
    () => GetSuggestedFriendsUsecase(repository: sl()),
  );

  sl.registerLazySingleton<friend_follow.FollowUserUsecase>(
    () => friend_follow.FollowUserUsecase(repository: sl()),
  );

  sl.registerLazySingleton<friend_unfollow.UnfollowUserUsecase>(
    () => friend_unfollow.UnfollowUserUsecase(repository: sl()),
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
  sl.registerFactory<HomeBloc>(
    () => HomeBloc(getUserProgressUsecase: sl(), getSkillByIdUsecase: sl()),
  );

  sl.registerFactory<ExerciseBloc>(
    () => ExerciseBloc(
      getExerciseUseCase: sl(),
      getReviewExerciseUsecase: sl(),
      submitLessonUsecase: sl(),
      getSpeakPoint: sl(),
      getImageDescriptionScore: sl(),
      consumeEnergyUseCase: sl(),
      energyBloc: sl<EnergyBloc>(),
    ),
  );

  sl.registerFactory<ProfileBloc>(
    () => ProfileBloc(
      getProfileUsecase: sl(),
      followUserUsecase: sl(),
      unfollowUserUsecase: sl(),
      getAchievementsUsecase: sl(),
    ),
  );

  sl.registerFactory<CurrencyBloc>(
    () => CurrencyBloc(getCurrencyBalanceUseCase: sl()),
  );

  sl.registerFactory<ChatBloc>(
    () => ChatBloc(chatUsecase: sl(), startChatUsecase: sl()),
  );

  sl.registerFactory<FriendBloc>(
    () => FriendBloc(
      searchUsersUsecase: sl(),
      getSuggestedFriendsUsecase: sl(),
      followUserUsecase: sl(),
      unfollowUserUsecase: sl(),
    ),
  );
}
