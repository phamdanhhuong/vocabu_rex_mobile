import 'package:vocabu_rex_mobile/quest/domain/entities/user_quest_entity.dart';
import 'package:vocabu_rex_mobile/quest/domain/repositories/quest_repository.dart';

class ClaimQuestUseCase {
  final QuestRepository repository;

  ClaimQuestUseCase({required this.repository});

  Future<UserQuestEntity> call(String questId) {
    return repository.claimQuest(questId);
  }
}
