import 'package:vocabu_rex_mobile/quest/domain/entities/user_quest_entity.dart';
import 'package:vocabu_rex_mobile/quest/domain/repositories/quest_repository.dart';

class GetCompletedQuestsUseCase {
  final QuestRepository repository;

  GetCompletedQuestsUseCase({required this.repository});

  Future<List<UserQuestEntity>> call() {
    return repository.getCompletedQuests();
  }
}
