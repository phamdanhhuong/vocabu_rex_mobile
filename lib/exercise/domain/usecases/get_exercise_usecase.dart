import 'package:vocabu_rex_mobile/exercise/domain/repositories/exercise_repository.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/lesson_entity.dart';

class GetExerciseUseCase {
  final ExerciseRepository repository;

  GetExerciseUseCase({required this.repository});

  Future<LessonEntity> call(String lessonId) {
    return repository.getExercisesByLessonId(lessonId);
  }
}
