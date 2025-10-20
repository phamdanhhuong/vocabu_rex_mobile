import 'package:vocabu_rex_mobile/exercise/domain/entities/entities.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/lesson_entity.dart';

abstract class ExerciseRepository {
  Future<LessonEntity> getExercisesByLessonId(String lessonId);
  Future<bool> submit(ExerciseResultEntity result);
  Future<PronunciationAnalysisEntity> getSpeakPoint(
    String path,
    String referenceText,
  );
  Future<ImageDescriptionScoreEntity> imgDescriptionScore(
    String content,
    String expectResult,
  );
}
