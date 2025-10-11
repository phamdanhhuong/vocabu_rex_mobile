import 'package:dio/dio.dart';
import 'package:vocabu_rex_mobile/network/api_constants.dart';
import 'package:vocabu_rex_mobile/network/base_api_service.dart';


class CurrencyService extends BaseApiService {
  // Singleton pattern
  static final CurrencyService _instance = CurrencyService._internal();
  factory CurrencyService() => _instance;
  CurrencyService._internal();

  Future<Map<String, dynamic>> getCurrencyBalance() async {
    try {
      final response = await client.get(ApiEndpoints.currencyStatus);
      return response.data["data"];
    } on DioException catch (error) {
      throw handleError(error);
    }
  }
}
