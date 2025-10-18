import '../entities/buy_energy_entity.dart';
import '../repositories/energy_repository.dart';

class BuyEnergyUseCase {
  final EnergyRepository repository;

  BuyEnergyUseCase({required this.repository});

  Future<BuyEnergyEntity> call({
    required int energyAmount,
    required String paymentMethod,
  }) {
    return repository.buyEnergy(
      energyAmount: energyAmount,
      paymentMethod: paymentMethod,
    );
  }
}
