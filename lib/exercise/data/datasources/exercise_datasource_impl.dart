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

  @override
  Future<LessonModel> fetchReviewExercises() async {
    final res = await exerciseService.getReviewExercises();
    final result = LessonModel.fromJson(res);
    return result;
  }

  @override
  Future<LessonModel> fetchPronunExercises() async {
    final res = await exerciseService.getPronunExercises();

    // Add missing fields for pronunciation exercises
    final adjustedData = Map<String, dynamic>.from(res);
    adjustedData['skillId'] =
        adjustedData['id'] ?? ''; // Use lesson id as skill id
    adjustedData['skillLevel'] = 1; // Default skill level
    adjustedData['createdAt'] = DateTime.now()
        .toIso8601String(); // Current time
    adjustedData['exerciseCount'] = adjustedData['exercises']?.length ?? 0;

    // Fix exercises data
    if (adjustedData['exercises'] != null) {
      final exercises = adjustedData['exercises'] as List;
      for (var exercise in exercises) {
        if (exercise is Map<String, dynamic>) {
          // Add missing fields for each exercise
          exercise['createdAt'] =
              exercise['createdAt'] ?? DateTime.now().toIso8601String();
          exercise['isInteractive'] = exercise['isInteractive'] ?? true;
          exercise['isContentBased'] = exercise['isContentBased'] ?? false;

          // Ensure required fields are not null
          exercise['id'] = exercise['id'] ?? '';
          exercise['lessonId'] = exercise['lessonId'] ?? adjustedData['id'];
          exercise['exerciseType'] = exercise['exerciseType'] ?? 'translate';
          exercise['position'] = exercise['position'] ?? 0;
        }
      }
    }

    // Remove fields that LessonModel doesn't have
    adjustedData.remove('description');
    adjustedData.remove('timestamp');

    // Ensure required fields are not null
    adjustedData['id'] = adjustedData['id'] ?? '';
    adjustedData['title'] = adjustedData['title'] ?? 'Pronunciation Lesson';
    adjustedData['position'] = adjustedData['position'] ?? 0;

    final result = LessonModel.fromJson(adjustedData);
    return result;
  }

  @override
  Future<SubmitResponseModel> submitPronunResult(
    ExerciseResultEntity result,
  ) async {
    final res = await exerciseService.submitPronunExersiceResult(result);

    // Adjust pronunciation response to match SubmitResponseModel structure
    final adjustedRes = Map<String, dynamic>.from(res);

    // Map pronunciation-specific fields to standard fields
    adjustedRes['skillId'] = adjustedRes['lessonId']; // Use lessonId as skillId
    adjustedRes['wordMasteriesUpdated'] =
        (adjustedRes['vowelMasteriesUpdated'] as List?)?.length ?? 0;
    adjustedRes['grammarMasteriesUpdated'] =
        (adjustedRes['consonantMasteriesUpdated'] as List?)?.length ?? 0;

    // Ensure required fields are not null
    adjustedRes['lessonId'] = adjustedRes['lessonId'] ?? '';
    adjustedRes['skillId'] = adjustedRes['skillId'] ?? adjustedRes['lessonId'];
    adjustedRes['totalExercises'] = adjustedRes['totalExercises'] ?? 0;
    adjustedRes['correctExercises'] = adjustedRes['correctExercises'] ?? 0;
    adjustedRes['accuracy'] = adjustedRes['accuracy'] ?? 0.0;
    adjustedRes['isLessonSuccessful'] =
        adjustedRes['isLessonSuccessful'] ?? false;
    adjustedRes['message'] =
        adjustedRes['message'] ?? 'Pronunciation lesson completed';

    final submitResponse = SubmitResponseModel.fromJson(adjustedRes);
    return submitResponse;
  }
}
