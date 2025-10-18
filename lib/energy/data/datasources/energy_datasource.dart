import '../models/get_energy_status_response_model.dart';
import '../models/buy_energy_request_model.dart';
import '../models/buy_energy_response_model.dart';

abstract class EnergyDatasource {
  Future<GetEnergyStatusResponseModel> getEnergyStatus({bool? includeTransactionHistory, int? historyLimit});
  Future<BuyEnergyResponseModel> buyEnergy(BuyEnergyRequestModel request);
}
