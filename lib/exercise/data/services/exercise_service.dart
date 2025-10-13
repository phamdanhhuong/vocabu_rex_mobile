import 'dart:io';

import 'package:dio/dio.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/entities.dart';
import 'package:vocabu_rex_mobile/network/api_constants.dart';
import 'package:vocabu_rex_mobile/network/base_api_service.dart';
import 'package:vocabu_rex_mobile/network/interceptors/auth_interceptor.dart';

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

  Future<Map<String, dynamic>> submitExersiceResult(
    ExerciseResultEntity result,
  ) async {
    try {
      final response = await client.post(
        '${ApiEndpoints.submit}',
        data: result.toJson(),
      );
      return response.data["data"];
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  Future<Map<String, dynamic>> speakCheck(
    String filePath,
    String reference_text,
  ) async {
    try {
      throw Exception();
    } on DioException catch (error) {
      throw handleError(error);
    }
  }
}
