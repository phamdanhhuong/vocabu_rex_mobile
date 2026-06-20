import 'package:dio/dio.dart';
import 'package:vocabu_rex_mobile/network/base_api_service.dart';

class MiniGameService extends BaseApiService {
  static final MiniGameService _instance = MiniGameService._internal();
  factory MiniGameService() => _instance;
  MiniGameService._internal();

  Future<Map<String, dynamic>> generateGame(String partId, String type) async {
    try {
      final response = await client.get('/mini-games/part/$partId/play', queryParameters: {
        'type': type.toUpperCase(),
      });
      return response.data;
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  Future<Map<String, dynamic>> submitScore(String partId, String type, int score, int timeSpentMs, int mistakesCount) async {
    try {
      final response = await client.post('/mini-games/submit', data: {
        'partId': partId,
        'gameType': type.toUpperCase(),
        'score': score,
        'timeSpentMs': timeSpentMs,
        'mistakesCount': mistakesCount,
      });
      return response.data;
    } on DioException catch (error) {
      throw handleError(error);
    }
  }
}
