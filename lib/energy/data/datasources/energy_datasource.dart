import '../models/get_energy_status_response_model.dart';
import '../models/buy_energy_request_model.dart';
import '../models/buy_energy_response_model.dart';
import '../models/consume_energy_response_model.dart';

abstract class EnergyDatasource {
  Future<GetEnergyStatusResponseModel> getEnergyStatus({bool? includeTransactionHistory, int? historyLimit});
  Future<BuyEnergyResponseModel> buyEnergy(BuyEnergyRequestModel request);
  
  /// Forward to server to consume energy for an incorrect exercise.
  /// Returns a typed response model.
  Future<ConsumeEnergyResponseModel> consumeEnergy({
    int amount = 1,
    String? referenceId,
    String? idempotencyKey,
    String? reason,
    String? activityType,
    Map<String, dynamic>? metadata,
    String? source,
  });
}
