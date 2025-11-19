import 'package:dio/dio.dart';
import 'package:vocabu_rex_mobile/network/api_constants.dart';
import 'package:vocabu_rex_mobile/network/base_api_service.dart';

class LeaderboardService extends BaseApiService {
  static final LeaderboardService _instance = LeaderboardService._internal();
  factory LeaderboardService() => _instance;
  LeaderboardService._internal();

  Future<Map<String, dynamic>> joinLeague() async {
    try {
      final response = await client.post(ApiEndpoints.leaderboardJoin);
      return response.data["data"] as Map<String, dynamic>;
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  Future<Map<String, dynamic>> getStandings() async {
    try {
      final response = await client.get(ApiEndpoints.leaderboardStandings);
      return response.data["data"] as Map<String, dynamic>;
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  Future<Map<String, dynamic>> getUserTier() async {
    try {
      final response = await client.get(ApiEndpoints.leaderboardTier);
      return response.data["data"] as Map<String, dynamic>;
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  Future<List<dynamic>> getHistory({int limit = 10}) async {
    try {
      final response = await client.get(
        ApiEndpoints.leaderboardHistory,
        queryParameters: {'limit': limit},
      );
      return response.data["data"] as List<dynamic>;
    } on DioException catch (error) {
      throw handleError(error);
    }
  }
}
