import 'energy_datasource.dart';
import '../models/get_energy_status_response_model.dart';
import 'package:dio/dio.dart';

class EnergyDatasourceImpl implements EnergyDatasource {
  final Dio dio;

  EnergyDatasourceImpl(this.dio);

  @override
  Future<GetEnergyStatusResponseModel> getEnergyStatus(String userId) async {
    final response = await dio.get('/energy/status', queryParameters: {'userId': userId});
    return GetEnergyStatusResponseModel.fromJson(response.data);
  }
}
