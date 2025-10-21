import 'package:vocabu_rex_mobile/exercise/data/datasources/exercise_datasource.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/exercise_result_entity.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/submit_response_entity.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/image_description_score_entity.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/pronunciation_analysis_entity.dart';
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

  @override
  Future<SubmitResponseEntity> submit(ExerciseResultEntity result) async {
    final submitRes = await exerciseDataSource.submitResult(result);
    // Map SubmitResponseModel to SubmitResponseEntity
    return SubmitResponseEntity.fromJson(submitRes.toJson());
  }

  @override
  Future<PronunciationAnalysisEntity> getSpeakPoint(
    String path,
    String referenceText,
  ) async {
    final pronunciation = await exerciseDataSource.speakCheck(
      path,
      referenceText,
    );
    return pronunciation.toEntity();
  }

  @override
  Future<ImageDescriptionScoreEntity> imgDescriptionScore(
    String content,
    String expectResult,
  ) async {
    final model = await exerciseDataSource.imgDescriptionScore(
      content,
      expectResult,
    );
    return ImageDescriptionScoreEntity.fromModel(model);
  }
}
