import 'package:dio/dio.dart';
import 'package:vocabu_rex_mobile/network/api_constants.dart';
import 'package:vocabu_rex_mobile/network/base_api_service.dart';
import '../models/buy_energy_request_model.dart';
import '../models/buy_energy_response_model.dart';

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

  Future<Map<String, dynamic>> buyEnergy(BuyEnergyRequestModel request) async {
    try {
      final response = await client.post(ApiEndpoints.energyBuy, data: request.toJson());
      return response.data['data'];
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  /// Consume energy for a single incorrect exercise attempt.
  /// amount: how many energy points to deduct (default 1)
  /// referenceId: optional reference (exerciseId)
  /// idempotencyKey: optional idempotency key to avoid double-charges
  Future<Map<String, dynamic>> consumeEnergy({int amount = 1, String? referenceId, String? idempotencyKey, String? reason, String? activityType, Map<String, dynamic>? metadata, String? source}) async {
    try {
      final body = <String, dynamic>{
        'amount': amount,
        if (referenceId != null) 'referenceId': referenceId,
        if (idempotencyKey != null) 'idempotencyKey': idempotencyKey,
        if (reason != null) 'reason': reason,
        if (activityType != null) 'activityType': activityType,
        if (metadata != null) 'metadata': metadata,
        if (source != null) 'source': source,
      };

      final response = await client.post(ApiEndpoints.energyConsume, data: body);
      return response.data['data'];
    } on DioException catch (error) {
      throw handleError(error);
    }
  }
}
