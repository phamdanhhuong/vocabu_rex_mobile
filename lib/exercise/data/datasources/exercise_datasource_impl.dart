import 'package:vocabu_rex_mobile/exercise/data/datasources/exercise_datasource.dart';
import 'package:vocabu_rex_mobile/exercise/data/models/image_description_score_model.dart';
import 'package:vocabu_rex_mobile/exercise/data/models/pronunciation_analysis_model.dart';
import 'package:vocabu_rex_mobile/exercise/data/models/submit_response_model.dart';
import 'package:vocabu_rex_mobile/exercise/data/services/exercise_service.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/entities.dart';
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

  @override
  Future<SubmitResponseModel> submitResult(ExerciseResultEntity result) async {
    final res = await exerciseService.submitExersiceResult(result);
    final submitResponse = SubmitResponseModel.fromJson(res);
    return submitResponse;
  }

  @override
  Future<PronunciationAnalysisResponse> speakCheck(
    String path,
    String referenceText,
  ) async {
    final res = await exerciseService.speakCheck(path, referenceText);
    final pronunciationAnalysisResponse =
        PronunciationAnalysisResponse.fromJson(res);
    return pronunciationAnalysisResponse;
  }

  @override
  Future<ImageDescriptionScoreModel> imgDescriptionScore(
    String content,
    String expectResult,
  ) async {
    final res = await exerciseService.imgDescriptionScore(
      content,
      expectResult,
    );
    final score = ImageDescriptionScoreModel.fromJson(res);
    return score;
  }
}
