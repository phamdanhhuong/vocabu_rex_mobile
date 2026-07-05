import 'package:vocabu_rex_mobile/minigame/domain/entities/minigame_session_entity.dart';
import 'package:vocabu_rex_mobile/minigame/domain/repositories/minigame_repository.dart';

class GetMiniGameUseCase {
  final MiniGameRepository repository;
  GetMiniGameUseCase(this.repository);

  Future<MiniGameSessionEntity> call({
    required String partId,
    required String gameType,
  }) {
    return repository.getSession(partId: partId, gameType: gameType);
  }
}
