import 'package:get_it/get_it.dart';
import 'package:vocabu_rex_mobile/friend/data/datasources/friend_datasource.dart';
import 'package:vocabu_rex_mobile/friend/data/datasources/friend_datasource_impl.dart';
import 'package:vocabu_rex_mobile/friend/data/repositories/friend_repository_impl.dart';
import 'package:vocabu_rex_mobile/friend/data/services/friend_service.dart';
import 'package:vocabu_rex_mobile/friend/domain/repositories/friend_repository.dart';
import 'package:vocabu_rex_mobile/friend/domain/usecases/follow_user_usecase.dart'
    as friend_follow;
import 'package:vocabu_rex_mobile/friend/domain/usecases/get_suggested_friends_usecase.dart';
import 'package:vocabu_rex_mobile/friend/domain/usecases/search_users_usecase.dart';
import 'package:vocabu_rex_mobile/friend/domain/usecases/unfollow_user_usecase.dart'
    as friend_unfollow;
import 'package:vocabu_rex_mobile/friend/ui/blocs/friend_bloc.dart';

final GetIt sl = GetIt.instance;

void initFriend() {
  // Service
  sl.registerLazySingleton<FriendService>(() => FriendService());

  // DataSource
  sl.registerLazySingleton<FriendDataSource>(() => FriendDataSourceImpl(sl()));

  // Repository
  sl.registerLazySingleton<FriendRepository>(
    () => FriendRepositoryImpl(friendDataSource: sl()),
  );

  // UseCase
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
  sl.registerFactory<FriendBloc>(
    () => FriendBloc(
      searchUsersUsecase: sl(),
      getSuggestedFriendsUsecase: sl(),
      followUserUsecase: sl(),
      unfollowUserUsecase: sl(),
    ),
  );
}
