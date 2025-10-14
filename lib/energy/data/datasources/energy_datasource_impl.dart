import 'energy_datasource.dart';
import '../models/get_energy_status_response_model.dart';
import '../services/energy_service.dart';

class EnergyDatasourceImpl implements EnergyDatasource {
  final EnergyService energyService;
  EnergyDatasourceImpl(this.energyService);

  @override
  Future<GetEnergyStatusResponseModel> getEnergyStatus({bool? includeTransactionHistory, int? historyLimit}) async {
    final res = await energyService.getEnergyStatus(
      includeTransactionHistory: includeTransactionHistory,
      historyLimit: historyLimit,
    );
    return GetEnergyStatusResponseModel.fromJson(res);
  }
}
