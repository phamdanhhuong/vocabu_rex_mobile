import 'package:vocabu_rex_mobile/exercise/data/models/image_description_score_model.dart';
import 'package:vocabu_rex_mobile/exercise/data/models/pronunciation_analysis_model.dart';
import 'package:vocabu_rex_mobile/exercise/data/models/submit_response_model.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/entities.dart';
import 'package:vocabu_rex_mobile/home/data/models/lesson_model.dart';

abstract class ExerciseDataSource {
  Future<LessonModel> fetchExercisesByLessonId(String lessonId);
  Future<SubmitResponseModel> submitResult(ExerciseResultEntity result);
  Future<PronunciationAnalysisResponse> speakCheck(
    String path,
    String referenceText,
  );
  Future<ImageDescriptionScoreModel> imgDescriptionScore(
    String content,
    String expectResult,
  );
}
