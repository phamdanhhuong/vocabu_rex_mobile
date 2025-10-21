import 'package:vocabu_rex_mobile/exercise/domain/repositories/exercise_repository.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/lesson_entity.dart';

class GetReviewExerciseUsecase {
  final ExerciseRepository repository;

  GetReviewExerciseUsecase({required this.repository});

  Future<LessonEntity> call() {
    return repository.getReviewExercises();
  }
}
