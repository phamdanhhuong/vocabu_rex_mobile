import 'package:vocabu_rex_mobile/quest/domain/entities/user_quest_entity.dart';
import 'package:vocabu_rex_mobile/quest/domain/repositories/quest_repository.dart';

class GetUserQuestsUseCase {
  final QuestRepository repository;

  GetUserQuestsUseCase({required this.repository});

  Future<List<UserQuestEntity>> call({bool activeOnly = false}) {
    return repository.getUserQuests(activeOnly: activeOnly);
  }
}
