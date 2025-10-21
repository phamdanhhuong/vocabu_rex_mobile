import 'package:vocabu_rex_mobile/exercise/domain/entities/entities.dart';
import 'package:vocabu_rex_mobile/exercise/domain/repositories/exercise_repository.dart';

class SubmitLessonUsecase {
  final ExerciseRepository repository;

  SubmitLessonUsecase({required this.repository});

  Future<SubmitResponseEntity> call(ExerciseResultEntity result) {
    return repository.submit(result);
  }
}
