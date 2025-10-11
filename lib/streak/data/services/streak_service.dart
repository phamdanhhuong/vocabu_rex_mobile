import 'package:dio/dio.dart';
import 'package:vocabu_rex_mobile/network/api_constants.dart';
import 'package:vocabu_rex_mobile/network/base_api_service.dart';

class StreakService extends BaseApiService {
  // Singleton pattern
  static final StreakService _instance = StreakService._internal();
  factory StreakService() => _instance;
  StreakService._internal();

  Future<Map<String, dynamic>> getStreakHistory({int? limit, bool? includeCurrentStreak}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      if (includeCurrentStreak != null) queryParams['includeCurrentStreak'] = includeCurrentStreak;
      final response = await client.get(ApiEndpoints.streakHistory, queryParameters: queryParams);
      return response.data["data"];
    } on DioException catch (error) {
      throw handleError(error);
    }
  }
}
