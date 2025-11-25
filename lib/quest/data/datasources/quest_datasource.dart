import 'package:vocabu_rex_mobile/quest/data/models/friends_quest_participant_model.dart';
import 'package:vocabu_rex_mobile/quest/data/models/quest_chest_model.dart';
import 'package:vocabu_rex_mobile/quest/data/models/user_quest_model.dart';

abstract class QuestDataSource {
  Future<List<UserQuestModel>> getUserQuests({bool activeOnly = false});
  Future<List<UserQuestModel>> getCompletedQuests();
  Future<UserQuestModel> claimQuest(String questId);
  Future<List<QuestChestModel>> getUnlockedChests();
  Future<QuestChestModel> openChest(String chestId);
  Future<List<FriendsQuestParticipantModel>> getFriendsQuestParticipants(
      String questKey, DateTime weekStartDate);
  Future<FriendsQuestParticipantModel> joinFriendsQuest(
      String questKey, DateTime weekStartDate, {bool isCreator});
  Future<FriendsQuestParticipantModel> inviteFriendToQuest(
      String questKey, String friendId, DateTime weekStartDate);
}
