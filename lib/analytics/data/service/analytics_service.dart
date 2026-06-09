import 'package:dio/dio.dart';
import 'package:vocabu_rex_mobile/network/api_constants.dart';
import 'package:vocabu_rex_mobile/network/base_api_service.dart';

class AnalyticsService extends BaseApiService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  Future<Map<String, dynamic>> getDashboard() async {
    try {
      final response = await client.get(ApiEndpoints.analyticsDashboard);
      return response.data["data"];
    } on DioException catch (error) {
      throw handleError(error);
    }
  }
}
