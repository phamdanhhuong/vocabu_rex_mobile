import '../entities/energy_entity.dart';
import '../entities/buy_energy_entity.dart';

abstract class EnergyRepository {
  Future<EnergyEntity> getEnergyStatus({
    bool? includeTransactionHistory,
    int? historyLimit,
  });
  
  Future<BuyEnergyEntity> buyEnergy({
    required int energyAmount,
    required String paymentMethod,
  });
}
