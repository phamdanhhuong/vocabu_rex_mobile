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
        '/battle/history',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      final body = response.data;
      if (body is List) return body;
      if (body is Map && body['data'] is List) return body['data'];
      return [];
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  Future<List<dynamic>> getPublicHistory(String userId, {int limit = 20, int offset = 0}) async {
    try {
      final response = await client.get(
        '/battle/history/$userId',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      final body = response.data;
      if (body is List) return body;
      if (body is Map && body['data'] is List) return body['data'];
      return [];
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await client.get('/battle/stats');
      final body = response.data;
      if (body is Map && body['data'] is Map) {
        return Map<String, dynamic>.from(body['data']);
      }
      return body as Map<String, dynamic>;
    } on DioException catch (error) {
      throw handleError(error);
    }
  }
}
