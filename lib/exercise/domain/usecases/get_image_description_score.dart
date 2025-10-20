import 'package:vocabu_rex_mobile/exercise/domain/entities/entities.dart';
import 'package:vocabu_rex_mobile/exercise/domain/repositories/exercise_repository.dart';

class GetImageDescriptionScore {
  final ExerciseRepository repository;

  GetImageDescriptionScore({required this.repository});

  Future<ImageDescriptionScoreEntity> call(
    String content,
    String expectResult,
  ) {
    return repository.imgDescriptionScore(content, expectResult);
  }
}
