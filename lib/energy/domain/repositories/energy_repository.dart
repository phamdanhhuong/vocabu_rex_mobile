import '../entities/energy_entity.dart';
import '../entities/buy_energy_entity.dart';
import '../../data/models/consume_energy_response_model.dart';

abstract class EnergyRepository {
  Future<EnergyEntity> getEnergyStatus({
    bool? includeTransactionHistory,
    int? historyLimit,
  });
  
  Future<BuyEnergyEntity> buyEnergy({
    required int energyAmount,
    required String paymentMethod,
  });

  /// Deduct energy for a single incorrect exercise attempt.
  /// Implementations should be idempotent when possible (use idempotencyKey).
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
