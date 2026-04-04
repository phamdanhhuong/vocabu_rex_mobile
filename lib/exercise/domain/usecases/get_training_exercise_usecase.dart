import 'package:vocabu_rex_mobile/exercise/domain/repositories/exercise_repository.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/lesson_entity.dart';

class GetTrainingExerciseUsecase {
  final ExerciseRepository repository;

  GetTrainingExerciseUsecase({required this.repository});

  Future<LessonEntity> call({String? trainingType}) {
    return repository.getTrainingExercises(trainingType: trainingType);
  }
}
