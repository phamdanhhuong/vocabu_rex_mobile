import 'package:vocabu_rex_mobile/exercise/domain/entities/entities.dart';
import 'package:vocabu_rex_mobile/exercise/domain/repositories/exercise_repository.dart';

class GetSpeakPoint {
  final ExerciseRepository repository;

  GetSpeakPoint({required this.repository});

  Future<PronunciationAnalysisEntity> call(String path, String referenceText) {
    return repository.getSpeakPoint(path, referenceText);
  }
}
