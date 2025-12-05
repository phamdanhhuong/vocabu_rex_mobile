import 'package:get_it/get_it.dart';
import 'package:vocabu_rex_mobile/assistant/data/datasources/chat_datasource.dart';
import 'package:vocabu_rex_mobile/assistant/data/datasources/chat_datasource_impl.dart';
import 'package:vocabu_rex_mobile/assistant/data/repositoriesImpl/assistant_repository_impl.dart';
import 'package:vocabu_rex_mobile/assistant/data/services/assistant_service.dart';
import 'package:vocabu_rex_mobile/assistant/domain/repositories/assistant_repository.dart';
import 'package:vocabu_rex_mobile/assistant/domain/usecases/chat_usecase.dart';
import 'package:vocabu_rex_mobile/assistant/domain/usecases/start_chat_usecase.dart';
import 'package:vocabu_rex_mobile/assistant/domain/usecases/get_user_conversations_usecase.dart';
import 'package:vocabu_rex_mobile/assistant/domain/usecases/get_conversation_messages_usecase.dart';
import 'package:vocabu_rex_mobile/assistant/ui/blocs/chat_bloc.dart';

final GetIt sl = GetIt.instance;

void initChat() {
  // Service
  sl.registerLazySingleton<AssistantService>(() => AssistantService());

  // DataSource
  sl.registerLazySingleton<ChatDatasource>(
    () => ChatDatasourceImpl(assistantService: sl()),
  );

  // Repository
  sl.registerLazySingleton<AssistantRepository>(
    () => AssistantRepositoryImpl(datasource: sl()),
  );

  // UseCase
  sl.registerLazySingleton<StartChatUsecase>(
    () => StartChatUsecase(repository: sl()),
  );

  sl.registerLazySingleton<ChatUsecase>(() => ChatUsecase(repository: sl()));

  sl.registerLazySingleton<GetUserConversationsUsecase>(
    () => GetUserConversationsUsecase(repository: sl()),
  );

  sl.registerLazySingleton<GetConversationMessagesUsecase>(
    () => GetConversationMessagesUsecase(repository: sl()),
  );

  // Bloc
  sl.registerFactory<ChatBloc>(
    () => ChatBloc(
      chatUsecase: sl(),
      startChatUsecase: sl(),
      getUserConversationsUsecase: sl(),
      getConversationMessagesUsecase: sl(),
    ),
  );
}
