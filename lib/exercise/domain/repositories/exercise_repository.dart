import 'package:vocabu_rex_mobile/exercise/domain/entities/entities.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/lesson_entity.dart';

abstract class ExerciseRepository {
  Future<LessonEntity> getExercisesByLessonId(String lessonId);
  Future<LessonEntity> getReviewExercises();
  Future<LessonEntity> getPronunExercises();

  /// Submit lesson results and return submit response from backend
  Future<SubmitResponseEntity> submit(ExerciseResultEntity result);
  Future<SubmitResponseEntity> submitPronun(ExerciseResultEntity result);
  Future<PronunciationAnalysisEntity> getSpeakPoint(
    String path,
    String referenceText,
  );
  Future<ImageDescriptionScoreEntity> imgDescriptionScore(
    String content,
    String expectResult,
  );
  Future<TranslateScoreEntity> translateScore(
    String userAnswer,
    String sourceText,
    String correctAnswer,
  );
  Future<WritingScoreEntity> writingScore(
    String userAnswer,
    WritingPromptMetaEntity meta,
  );
}
