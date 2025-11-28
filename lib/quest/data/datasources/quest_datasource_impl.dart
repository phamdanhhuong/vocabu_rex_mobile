import 'package:vocabu_rex_mobile/quest/data/datasources/quest_datasource.dart';
import 'package:vocabu_rex_mobile/quest/data/models/friends_quest_participant_model.dart';
import 'package:vocabu_rex_mobile/quest/data/models/quest_chest_model.dart';
import 'package:vocabu_rex_mobile/quest/data/models/user_quest_model.dart';
import 'package:vocabu_rex_mobile/quest/data/services/quest_service.dart';

class QuestDataSourceImpl implements QuestDataSource {
  final QuestService questService;

  QuestDataSourceImpl(this.questService);

  @override
  Future<List<UserQuestModel>> getUserQuests({bool activeOnly = false}) async {
    final res = await questService.getUserQuests(activeOnly: activeOnly);
    return res.map((json) => UserQuestModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<UserQuestModel>> getCompletedQuests() async {
    final res = await questService.getCompletedQuests();
    return res.map((json) => UserQuestModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<UserQuestModel> claimQuest(String questId) async {
    final res = await questService.claimQuest(questId);
    return UserQuestModel.fromJson(res);
  }

  @override
  Future<List<QuestChestModel>> getUnlockedChests() async {
    final res = await questService.getUnlockedChests();
    return res.map((json) => QuestChestModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<QuestChestModel> openChest(String chestId) async {
    final res = await questService.openChest(chestId);
    return QuestChestModel.fromJson(res);
  }

  @override
  Future<List<FriendsQuestParticipantModel>> getFriendsQuestParticipants(
      String questKey, DateTime weekStartDate) async {
    final res = await questService.getFriendsQuestParticipants(
        questKey, weekStartDate);
    return res
        .map((json) =>
            FriendsQuestParticipantModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<FriendsQuestParticipantModel> joinFriendsQuest(
      String questKey, DateTime weekStartDate, {bool isCreator = false}) async {
    final res = await questService.joinFriendsQuest(questKey, weekStartDate,
        isCreator: isCreator);
    return FriendsQuestParticipantModel.fromJson(res);
  }

  @override
  Future<FriendsQuestParticipantModel> inviteFriendToQuest(
      String questKey, String friendId, DateTime weekStartDate) async {
    final res = await questService.inviteFriendToQuest(
        questKey, friendId, weekStartDate);
    return FriendsQuestParticipantModel.fromJson(res);
  }
}
