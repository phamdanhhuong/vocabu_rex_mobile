import 'package:vocabu_rex_mobile/quest/domain/entities/friends_quest_participant_entity.dart';
import 'package:vocabu_rex_mobile/quest/domain/repositories/quest_repository.dart';

class InviteFriendToQuestUseCase {
  final QuestRepository repository;

  InviteFriendToQuestUseCase({required this.repository});

  Future<FriendsQuestParticipantEntity> call(
      String questKey, String friendId, DateTime weekStartDate) {
    return repository.inviteFriendToQuest(questKey, friendId, weekStartDate);
  }
}
