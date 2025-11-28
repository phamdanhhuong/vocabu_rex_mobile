import 'package:vocabu_rex_mobile/quest/domain/entities/friends_quest_participant_entity.dart';
import 'package:vocabu_rex_mobile/quest/domain/repositories/quest_repository.dart';

class GetFriendsQuestParticipantsUseCase {
  final QuestRepository repository;

  GetFriendsQuestParticipantsUseCase({required this.repository});

  Future<List<FriendsQuestParticipantEntity>> call(
      String questKey, DateTime weekStartDate) {
    return repository.getFriendsQuestParticipants(questKey, weekStartDate);
  }
}
