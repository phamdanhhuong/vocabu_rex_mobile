import 'package:vocabu_rex_mobile/exercise/data/datasources/exercise_datasource.dart';
import 'package:vocabu_rex_mobile/exercise/data/services/exercise_service.dart';
import 'package:vocabu_rex_mobile/home/data/models/lesson_model.dart';

class ExerciseDataSourceImpl implements ExerciseDataSource {
  final ExerciseService exerciseService;
  ExerciseDataSourceImpl(this.exerciseService);
  @override
  Future<LessonModel> fetchExercisesByLessonId(String lessonId) async {
    final res = await exerciseService.getExercisesByLessonId(lessonId);
    final result = LessonModel.fromJson(res);
    return result;
  }
}
