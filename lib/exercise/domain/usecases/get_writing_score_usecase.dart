import 'package:vocabu_rex_mobile/exercise/domain/entities/entities.dart';
import 'package:vocabu_rex_mobile/exercise/domain/repositories/exercise_repository.dart';

class GetWritingScoreUseCase {
  final ExerciseRepository repository;

  GetWritingScoreUseCase({required this.repository});

  Future<WritingScoreEntity> call(
    String userAnswer,
    WritingPromptMetaEntity meta,
  ) {
    return repository.writingScore(userAnswer, meta);
  }
}
