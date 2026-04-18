import 'package:dio/dio.dart';
import 'package:vocabu_rex_mobile/network/api_constants.dart';
import 'package:vocabu_rex_mobile/network/base_api_service.dart';

class BattleApiService extends BaseApiService {
  static final BattleApiService _instance = BattleApiService._internal();
  factory BattleApiService() => _instance;
  BattleApiService._internal();

  Future<List<dynamic>> getHistory({int limit = 20, int offset = 0}) async {
    try {
      final response = await client.get(
        '${ApiEndpoints.baseUrl}/battle/history',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      return response.data is List ? response.data : [];
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await client.get('${ApiEndpoints.baseUrl}/battle/stats');
      return response.data as Map<String, dynamic>;
    } on DioException catch (error) {
      throw handleError(error);
    }
  }
}
