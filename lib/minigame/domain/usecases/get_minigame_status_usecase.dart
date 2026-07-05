import 'package:vocabu_rex_mobile/minigame/domain/entities/minigame_status_entity.dart';
import 'package:vocabu_rex_mobile/minigame/domain/repositories/minigame_repository.dart';

class GetMiniGameStatusUseCase {
  final MiniGameRepository repository;
  GetMiniGameStatusUseCase(this.repository);

  Future<List<MiniGameStatusEntity>> call(String partId) {
    return repository.getStatus(partId);
  }
}
