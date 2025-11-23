import 'package:dio/dio.dart';
import 'package:vocabu_rex_mobile/network/api_constants.dart';
import 'package:vocabu_rex_mobile/network/base_api_service.dart';

class HomeService extends BaseApiService {
  // Singleton pattern
  static final HomeService _instance = HomeService._internal();
  factory HomeService() => _instance;
  HomeService._internal();

  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await client.get(ApiEndpoints.profile);
      return response.data["data"];
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  Future<Map<String, dynamic>> getUserProgress() async {
    try {
      final response = await client.get(ApiEndpoints.progress);
      return response.data["data"];
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  Future<List<dynamic>> getLearningParts() async {
    try {
      final response = await client.get(ApiEndpoints.learningPart);
      return response.data["data"];
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  Future<Map<String, dynamic>> getSkillById(String id) async {
    try {
      final response = await client.get(ApiEndpoints.skill + id);
      return response.data["data"];
    } on DioException catch (error) {
      throw handleError(error);
    }
  }
}
