import 'package:vocabu_rex_mobile/home/domain/entities/lesson_entity.dart';

abstract class ExerciseRepository {
  Future<LessonEntity> getExercisesByLessonId(String lessonId);
}
