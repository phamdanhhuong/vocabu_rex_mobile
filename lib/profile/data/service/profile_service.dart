import 'package:dio/dio.dart';
import 'package:vocabu_rex_mobile/network/api_constants.dart';
import 'package:vocabu_rex_mobile/network/base_api_service.dart';

class ProfileService extends BaseApiService {
  // Singleton pattern
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();
  
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await client.get(ApiEndpoints.profile);
      return response.data["data"];
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  Future<void> followUser(String userId) async {
    try {
      await client.post(ApiEndpoints.followUser(userId));
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  Future<void> unfollowUser(String userId) async {
    try {
      await client.delete(ApiEndpoints.unfollowUser(userId));
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await client.put(
        ApiEndpoints.updateProfile,
        data: profileData,
      );
      return response.data["data"];
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  Future<List<Map<String, dynamic>>> getAchievements({bool onlyUnlocked = false}) async {
    try {
      final endpoint = onlyUnlocked 
          ? ApiEndpoints.achievementsUnlocked 
          : ApiEndpoints.achievements;
      final response = await client.get(endpoint);
      return List<Map<String, dynamic>>.from(response.data["data"]);
    } on DioException catch (error) {
      throw handleError(error);
    }
  }
}
