import 'package:vocabu_rex_mobile/profile/domain/entities/profile_entity.dart';
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
    // TODO: Gọi API follow user
    throw UnimplementedError();
  }

  Future<void> unfollowUser(String userId) async {
    // TODO: Gọi API unfollow user
    throw UnimplementedError();
  }

  Future<Map<String, dynamic>> updateProfile(ProfileEntity profile) async {
    // TODO: Gọi API cập nhật profile
    throw UnimplementedError();
  }
}
