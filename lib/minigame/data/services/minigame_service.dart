import 'package:dio/dio.dart';
import 'package:vocabu_rex_mobile/network/api_constants.dart';
import 'package:vocabu_rex_mobile/network/base_api_service.dart';

class MiniGameService extends BaseApiService {
  static final MiniGameService _instance = MiniGameService._internal();
  factory MiniGameService() => _instance;
  MiniGameService._internal();

  /// GET /mini-games/part/:partId/play?type=ARCADE
  Future<Map<String, dynamic>> getSession({
    required String partId,
    required String gameType,
  }) async {
    try {
      final response = await client.get(
        ApiEndpoints.miniGamePlay(partId),
        queryParameters: {'type': gameType},
      );
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  /// POST /mini-games/submit
  Future<Map<String, dynamic>> submit({
    required String partId,
    required String gameType,
    required int score,
    required int timeSpentMs,
    required int mistakesCount,
  }) async {
    try {
      final response = await client.post(
        ApiEndpoints.miniGameSubmit,
        data: {
          'partId': partId,
          'gameType': gameType,
          'score': score,
          'timeSpentMs': timeSpentMs,
          'mistakesCount': mistakesCount,
        },
      );
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  /// GET /mini-games/part/:partId/status
  Future<List<dynamic>> getStatus(String partId) async {
    try {
      final response = await client.get(ApiEndpoints.miniGameStatus(partId));
      final data = response.data['data'];
      if (data is List) return data;
      return [];
    } on DioException catch (e) {
      throw handleError(e);
    }
  }
}
