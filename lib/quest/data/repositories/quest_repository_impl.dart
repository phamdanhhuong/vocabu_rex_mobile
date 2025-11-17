import 'package:vocabu_rex_mobile/quest/data/datasources/quest_datasource.dart';
import 'package:vocabu_rex_mobile/quest/domain/entities/quest_chest_entity.dart';
import 'package:vocabu_rex_mobile/quest/domain/entities/user_quest_entity.dart';
import 'package:vocabu_rex_mobile/quest/domain/repositories/quest_repository.dart';

class QuestRepositoryImpl implements QuestRepository {
  final QuestDataSource questDataSource;

  QuestRepositoryImpl({required this.questDataSource});

  @override
  Future<List<UserQuestEntity>> getUserQuests({bool activeOnly = false}) async {
    final models = await questDataSource.getUserQuests(activeOnly: activeOnly);
    return models.map((model) => UserQuestEntity.fromModel(model)).toList();
  }

  @override
  Future<List<UserQuestEntity>> getCompletedQuests() async {
    final models = await questDataSource.getCompletedQuests();
    return models.map((model) => UserQuestEntity.fromModel(model)).toList();
  }

  @override
  Future<UserQuestEntity> claimQuest(String questId) async {
    final model = await questDataSource.claimQuest(questId);
    return UserQuestEntity.fromModel(model);
  }

  @override
  Future<List<QuestChestEntity>> getUnlockedChests() async {
    final models = await questDataSource.getUnlockedChests();
    return models.map((model) => QuestChestEntity.fromModel(model)).toList();
  }

  @override
  Future<QuestChestEntity> openChest(String chestId) async {
    final model = await questDataSource.openChest(chestId);
    return QuestChestEntity.fromModel(model);
  }
}
