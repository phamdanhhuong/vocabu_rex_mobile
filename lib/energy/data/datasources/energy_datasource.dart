import '../models/get_energy_status_response_model.dart';

abstract class EnergyDatasource {
  Future<GetEnergyStatusResponseModel> getEnergyStatus({bool? includeTransactionHistory, int? historyLimit});
}
