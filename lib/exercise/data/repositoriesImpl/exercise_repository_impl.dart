import 'package:vocabu_rex_mobile/exercise/data/datasources/exercise_datasource.dart';
import 'package:vocabu_rex_mobile/exercise/domain/repositories/exercise_repository.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/lesson_entity.dart';

class ExcerciseRepositoryImpl implements ExerciseRepository {
  final ExerciseDataSource exerciseDataSource;
  ExcerciseRepositoryImpl({required this.exerciseDataSource});
  @override
  Future<LessonEntity> getExercisesByLessonId(String lessonId) async {
    final lessonModel = await exerciseDataSource.fetchExercisesByLessonId(
      lessonId,
    );
    return LessonEntity.fromModel(lessonModel);
  }
}
