import 'package:dio/dio.dart';
import 'package:vocabu_rex_mobile/network/api_constants.dart';
import 'package:vocabu_rex_mobile/network/base_api_service.dart';

class ExerciseService extends BaseApiService {
  // Singleton pattern
  static final ExerciseService _instance = ExerciseService._internal();
  factory ExerciseService() => _instance;
  ExerciseService._internal();
  Future<Map<String, dynamic>> getExercisesByLessonId(String lessonId) async {
    try {
      final response = await client.get('${ApiEndpoints.exercise}$lessonId');
      return response.data["data"];
    } on DioException catch (error) {
      throw handleError(error);
    }
  }
}
