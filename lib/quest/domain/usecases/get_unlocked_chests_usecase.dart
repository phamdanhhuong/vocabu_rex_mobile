import 'package:vocabu_rex_mobile/quest/domain/entities/quest_chest_entity.dart';
import 'package:vocabu_rex_mobile/quest/domain/repositories/quest_repository.dart';

class GetUnlockedChestsUseCase {
  final QuestRepository repository;

  GetUnlockedChestsUseCase({required this.repository});

  Future<List<QuestChestEntity>> call() {
    return repository.getUnlockedChests();
  }
}
