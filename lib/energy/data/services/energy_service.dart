import 'package:dio/dio.dart';
import 'package:vocabu_rex_mobile/network/api_constants.dart';
import 'package:vocabu_rex_mobile/network/base_api_service.dart';

class EnergyService extends BaseApiService {
  // Singleton pattern
  static final EnergyService _instance = EnergyService._internal();
  factory EnergyService() => _instance;
  EnergyService._internal();

  Future<Map<String, dynamic>> getEnergyStatus({bool? includeTransactionHistory, int? historyLimit}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (includeTransactionHistory != null) queryParams['includeTransactionHistory'] = includeTransactionHistory;
      if (historyLimit != null) queryParams['historyLimit'] = historyLimit;
      final response = await client.get(ApiEndpoints.energyStatus, queryParameters: queryParams);
      return response.data['data'];
    } on DioException catch (error) {
      throw handleError(error);
    }
  }
}
