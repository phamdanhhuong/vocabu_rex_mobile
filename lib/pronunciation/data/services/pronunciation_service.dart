import 'package:dio/dio.dart';
import 'package:vocabu_rex_mobile/network/api_constants.dart';
import 'package:vocabu_rex_mobile/network/base_api_service.dart';

class PronunciationServive extends BaseApiService {
  // Singleton pattern
  static final PronunciationServive _instance =
      PronunciationServive._internal();
  factory PronunciationServive() => _instance;
  PronunciationServive._internal();

  Future<Map<String, dynamic>> getProgress() async {
    try {
      final response = await client.get(ApiEndpoints.getPronunProgress);
      return response.data["data"];
    } on DioException catch (error) {
      throw handleError(error);
    }
  }
}
