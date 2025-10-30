import 'package:dio/dio.dart';
import 'package:vocabu_rex_mobile/network/api_constants.dart';
import 'package:vocabu_rex_mobile/network/base_api_service.dart';

class FriendService extends BaseApiService {
  // Singleton pattern
  static final FriendService _instance = FriendService._internal();
  factory FriendService() => _instance;
  FriendService._internal();
  
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final response = await client.get(
        ApiEndpoints.searchUsers,
        queryParameters: {'query': query},
      );
      return List<Map<String, dynamic>>.from(response.data["data"]);
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  Future<List<Map<String, dynamic>>> getSuggestedFriends() async {
    try {
      final response = await client.get(ApiEndpoints.suggestedFriends);
      return List<Map<String, dynamic>>.from(response.data["data"]);
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

  Future<List<Map<String, dynamic>>> getFollowingUsers({String? userId, int limit = 50, int offset = 0}) async {
    try {
      final response = await client.get(
        ApiEndpoints.followingUsers,
        queryParameters: {
          if (userId != null) 'userId': userId,
          'limit': limit,
          'offset': offset,
        },
      );
      return List<Map<String, dynamic>>.from(response.data["data"]);
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  Future<List<Map<String, dynamic>>> getFollowersUsers({String? userId, int limit = 50, int offset = 0}) async {
    try {
      final response = await client.get(
        ApiEndpoints.followersUsers,
        queryParameters: {
          if (userId != null) 'userId': userId,
          'limit': limit,
          'offset': offset,
        },
      );
      return List<Map<String, dynamic>>.from(response.data["data"]);
    } on DioException catch (error) {
      throw handleError(error);
    }
  }
}
