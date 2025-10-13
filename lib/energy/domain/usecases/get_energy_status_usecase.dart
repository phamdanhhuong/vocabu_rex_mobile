import '../entities/energy_entity.dart';
import '../repositories/energy_repository.dart';

class GetEnergyStatusUseCase {
  final EnergyRepository repository;

  GetEnergyStatusUseCase({required this.repository});

  Future<EnergyEntity> call({bool? includeTransactionHistory, int? historyLimit}) {
    return repository.getEnergyStatus(
      includeTransactionHistory: includeTransactionHistory,
      historyLimit: historyLimit,
    );
  }
}
