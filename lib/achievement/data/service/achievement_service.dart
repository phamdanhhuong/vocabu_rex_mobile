import 'package:dio/dio.dart';
import 'package:vocabu_rex_mobile/network/api_constants.dart';
import 'package:vocabu_rex_mobile/network/base_api_service.dart';

class AchievementService extends BaseApiService {
  // Singleton pattern
  static final AchievementService _instance = AchievementService._internal();
  factory AchievementService() => _instance;
  AchievementService._internal();

  /// Get all achievements for the current user
  /// If [onlyUnlocked] is true, only return unlocked achievements
  Future<List<Map<String, dynamic>>> getAchievements({
    bool onlyUnlocked = false,
  }) async {
    try {
      final endpoint = onlyUnlocked
          ? ApiEndpoints.achievementsUnlocked
          : ApiEndpoints.achievements;
      final response = await client.get(endpoint);
      return List<Map<String, dynamic>>.from(response.data['data']);
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  /// Get achievements summary (personal + highest tier for each category)
  Future<Map<String, dynamic>> getAchievementsSummary() async {
    try {
      final response = await client.get(ApiEndpoints.achievementsSummary);
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (error) {
      throw handleError(error);
    }
  }
}
