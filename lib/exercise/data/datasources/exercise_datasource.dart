import 'package:vocabu_rex_mobile/exercise/data/models/image_description_score_model.dart';
import 'package:vocabu_rex_mobile/exercise/data/models/pronunciation_analysis_model.dart';
import 'package:vocabu_rex_mobile/exercise/data/models/submit_response_model.dart';
import 'package:vocabu_rex_mobile/exercise/data/models/translate_score_model.dart';
import 'package:vocabu_rex_mobile/exercise/data/models/writing_score_model.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/entities.dart';
import 'package:vocabu_rex_mobile/home/data/models/lesson_model.dart';

abstract class ExerciseDataSource {
  Future<LessonModel> fetchExercisesByLessonId(String lessonId);
  Future<LessonModel> fetchReviewExercises();
  Future<LessonModel> fetchPronunExercises();
  Future<SubmitResponseModel> submitResult(ExerciseResultEntity result);
  Future<SubmitResponseModel> submitPronunResult(ExerciseResultEntity result);
  Future<PronunciationAnalysisResponse> speakCheck(
    String path,
    String referenceText,
  );
  Future<ImageDescriptionScoreModel> imgDescriptionScore(
    String content,
    String expectResult,
  );
  Future<TranslateScoreModel> translateScore(
    String userAnswer,
    String sourceText,
    String correctAnswer,
  );
  Future<WritingScoreModel> writingScore(
    String userAnswer,
    WritingPromptMetaEntity meta,
  );
}
