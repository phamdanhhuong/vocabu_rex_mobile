import 'package:vocabu_rex_mobile/exercise/domain/entities/entities.dart';
import 'package:vocabu_rex_mobile/exercise/domain/repositories/exercise_repository.dart';

class GetTranslateScoreUseCase {
  final ExerciseRepository repository;

  GetTranslateScoreUseCase({required this.repository});

  Future<TranslateScoreEntity> call(
    String userAnswer,
    String sourceText,
    String correctAnswer,
  ) {
    return repository.translateScore(userAnswer, sourceText, correctAnswer);
  }
}
