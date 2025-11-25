import 'package:get_it/get_it.dart';
import 'package:vocabu_rex_mobile/feed/data/datasources/feed_datasource.dart';
import 'package:vocabu_rex_mobile/feed/data/datasources/feed_datasource_impl.dart';
import 'package:vocabu_rex_mobile/feed/data/repositories/feed_repository_impl.dart';
import 'package:vocabu_rex_mobile/feed/domain/repositories/feed_repository.dart';
import 'package:vocabu_rex_mobile/feed/domain/usecases/get_feed_posts_usecase.dart';
import 'package:vocabu_rex_mobile/feed/domain/usecases/toggle_reaction_usecase.dart';
import 'package:vocabu_rex_mobile/feed/domain/usecases/add_comment_usecase.dart';
import 'package:vocabu_rex_mobile/feed/domain/usecases/delete_comment_usecase.dart';
import 'package:vocabu_rex_mobile/feed/domain/usecases/get_post_reactions_usecase.dart';
import 'package:vocabu_rex_mobile/feed/ui/blocs/feed_bloc.dart';
import 'package:vocabu_rex_mobile/feed/ui/blocs/reaction_bloc.dart';

final GetIt sl = GetIt.instance;

void initFeed() {
  // DataSource
  sl.registerLazySingleton<FeedDataSource>(() => FeedDataSourceImpl());

  // Repository
  sl.registerLazySingleton<FeedRepository>(
    () => FeedRepositoryImpl(sl()),
  );

  // UseCases
  sl.registerLazySingleton<GetFeedPostsUseCase>(
    () => GetFeedPostsUseCase(sl()),
  );

  sl.registerLazySingleton<ToggleReactionUseCase>(
    () => ToggleReactionUseCase(sl()),
  );

  sl.registerLazySingleton<AddCommentUseCase>(
    () => AddCommentUseCase(sl()),
  );

  sl.registerLazySingleton<DeleteCommentUseCase>(
    () => DeleteCommentUseCase(sl()),
  );

  sl.registerLazySingleton<GetPostReactionsUseCase>(
    () => GetPostReactionsUseCase(sl()),
  );

  // Blocs
  sl.registerFactory<FeedBloc>(
    () => FeedBloc(
      getFeedPostsUseCase: sl(),
      toggleReactionUseCase: sl(),
      addCommentUseCase: sl(),
      deleteCommentUseCase: sl(),
    ),
  );

  sl.registerFactory<ReactionBloc>(
    () => ReactionBloc(
      getPostReactionsUseCase: sl(),
    ),
  );
}
