import 'package:vocabu_rex_mobile/quest/domain/entities/quest_chest_entity.dart';
import 'package:vocabu_rex_mobile/quest/domain/repositories/quest_repository.dart';

class OpenChestUseCase {
  final QuestRepository repository;

  OpenChestUseCase({required this.repository});

  Future<QuestChestEntity> call(String chestId) {
    return repository.openChest(chestId);
  }
}
