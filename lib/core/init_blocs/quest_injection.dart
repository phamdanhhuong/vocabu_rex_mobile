import 'package:get_it/get_it.dart';
import 'package:vocabu_rex_mobile/quest/data/services/quest_service.dart';
import 'package:vocabu_rex_mobile/quest/data/datasources/quest_datasource.dart';
import 'package:vocabu_rex_mobile/quest/data/datasources/quest_datasource_impl.dart';
import 'package:vocabu_rex_mobile/quest/data/repositories/quest_repository_impl.dart';
import 'package:vocabu_rex_mobile/quest/domain/repositories/quest_repository.dart';
import 'package:vocabu_rex_mobile/quest/domain/usecases/get_user_quests_usecase.dart';
import 'package:vocabu_rex_mobile/quest/domain/usecases/get_completed_quests_usecase.dart';
import 'package:vocabu_rex_mobile/quest/domain/usecases/claim_quest_usecase.dart';
import 'package:vocabu_rex_mobile/quest/domain/usecases/get_unlocked_chests_usecase.dart';
import 'package:vocabu_rex_mobile/quest/domain/usecases/open_chest_usecase.dart';
import 'package:vocabu_rex_mobile/quest/domain/usecases/get_friends_quest_participants_usecase.dart';
import 'package:vocabu_rex_mobile/quest/domain/usecases/invite_friend_to_quest_usecase.dart';
import 'package:vocabu_rex_mobile/quest/domain/usecases/join_friends_quest_usecase.dart';
import 'package:vocabu_rex_mobile/quest/ui/blocs/quest_bloc.dart';
import 'package:vocabu_rex_mobile/quest/ui/blocs/quest_chest_bloc.dart';
import 'package:vocabu_rex_mobile/quest/ui/blocs/friends_quest_bloc.dart';

final GetIt sl = GetIt.instance;

void initQuest() {
  // Service
  sl.registerLazySingleton<QuestService>(() => QuestService());

  // DataSource
  sl.registerLazySingleton<QuestDataSource>(
    () => QuestDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<QuestRepository>(
    () => QuestRepositoryImpl(questDataSource: sl()),
  );

  // UseCases
  sl.registerLazySingleton<GetUserQuestsUseCase>(
    () => GetUserQuestsUseCase(repository: sl()),
  );

  sl.registerLazySingleton<GetCompletedQuestsUseCase>(
    () => GetCompletedQuestsUseCase(repository: sl()),
  );

  sl.registerLazySingleton<ClaimQuestUseCase>(
    () => ClaimQuestUseCase(repository: sl()),
  );

  sl.registerLazySingleton<GetUnlockedChestsUseCase>(
    () => GetUnlockedChestsUseCase(repository: sl()),
  );

  sl.registerLazySingleton<OpenChestUseCase>(
    () => OpenChestUseCase(repository: sl()),
  );

  sl.registerLazySingleton<GetFriendsQuestParticipantsUseCase>(
    () => GetFriendsQuestParticipantsUseCase(repository: sl()),
  );

  sl.registerLazySingleton<InviteFriendToQuestUseCase>(
    () => InviteFriendToQuestUseCase(repository: sl()),
  );

  sl.registerLazySingleton<JoinFriendsQuestUseCase>(
    () => JoinFriendsQuestUseCase(repository: sl()),
  );

  // Blocs
  sl.registerFactory<QuestBloc>(
    () => QuestBloc(
      getUserQuestsUseCase: sl(),
      getCompletedQuestsUseCase: sl(),
      claimQuestUseCase: sl(),
    ),
  );

  sl.registerFactory<QuestChestBloc>(
    () => QuestChestBloc(
      getUnlockedChestsUseCase: sl(),
      openChestUseCase: sl(),
    ),
  );

  sl.registerFactory<FriendsQuestBloc>(
    () => FriendsQuestBloc(
      getFriendsQuestParticipantsUseCase: sl(),
      inviteFriendToQuestUseCase: sl(),
      joinFriendsQuestUseCase: sl(),
    ),
  );
}
