import 'package:vocabu_rex_mobile/minigame/domain/entities/minigame_result_entity.dart';
import 'package:vocabu_rex_mobile/minigame/domain/repositories/minigame_repository.dart';

class SubmitMiniGameUseCase {
  final MiniGameRepository repository;
  SubmitMiniGameUseCase(this.repository);

  Future<MiniGameResultEntity> call({
    required String partId,
    required String gameType,
    required int score,
    required int timeSpentMs,
    required int mistakesCount,
  }) {
    return repository.submit(
      partId: partId,
      gameType: gameType,
      score: score,
      timeSpentMs: timeSpentMs,
      mistakesCount: mistakesCount,
    );
  }
}
