import '../entities/energy_entity.dart';

abstract class EnergyRepository {
  Future<EnergyEntity> getEnergyStatus({
    bool? includeTransactionHistory,
    int? historyLimit,
  });
}
