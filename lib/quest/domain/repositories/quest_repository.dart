import 'package:vocabu_rex_mobile/quest/domain/entities/quest_chest_entity.dart';
import 'package:vocabu_rex_mobile/quest/domain/entities/user_quest_entity.dart';

abstract class QuestRepository {
  Future<List<UserQuestEntity>> getUserQuests({bool activeOnly = false});
  Future<List<UserQuestEntity>> getCompletedQuests();
  Future<UserQuestEntity> claimQuest(String questId);
  Future<List<QuestChestEntity>> getUnlockedChests();
  Future<QuestChestEntity> openChest(String chestId);
}
