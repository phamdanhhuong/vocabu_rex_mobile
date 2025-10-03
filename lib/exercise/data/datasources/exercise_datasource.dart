import 'package:vocabu_rex_mobile/home/data/models/lesson_model.dart';

abstract class ExerciseDataSource {
  Future<LessonModel> fetchExercisesByLessonId(String lessonId);
}
