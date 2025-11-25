import 'package:vocabu_rex_mobile/quest/domain/entities/friends_quest_participant_entity.dart';
import 'package:vocabu_rex_mobile/quest/domain/repositories/quest_repository.dart';

class JoinFriendsQuestUseCase {
  final QuestRepository repository;

  JoinFriendsQuestUseCase({required this.repository});

  Future<FriendsQuestParticipantEntity> call(
      String questKey, DateTime weekStartDate, {bool isCreator = false}) {
    return repository.joinFriendsQuest(questKey, weekStartDate,
        isCreator: isCreator);
  }
}
