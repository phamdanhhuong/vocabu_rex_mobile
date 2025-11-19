import 'package:vocabu_rex_mobile/exercise/domain/repositories/exercise_repository.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/lesson_entity.dart';

class GetPronunExercisesUseCase {
  final ExerciseRepository repository;

  GetPronunExercisesUseCase(this.repository);

  Future<LessonEntity> call() async {
    return await repository.getPronunExercises();
  }
}
