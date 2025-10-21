import '../repositories/energy_repository.dart';
import '../../data/models/consume_energy_response_model.dart';

class ConsumeEnergyUseCase {
  final EnergyRepository repository;

  ConsumeEnergyUseCase({required this.repository});

  /// Deduct energy for a single incorrect exercise attempt.
  /// amount: how many points to deduct (default 1)
  /// referenceId and idempotencyKey are forwarded to the repository if supported.
  Future<ConsumeEnergyResponseModel> call({
    int amount = 1,
    String? referenceId,
    String? idempotencyKey,
    String? reason,
    String? activityType,
    Map<String, dynamic>? metadata,
    String? source,
  }) async {
    // Call the repository's consumeEnergy method. Implementations should
    // forward to the API/service and be idempotent when possible.
    return await repository.consumeEnergy(
      amount: amount,
      referenceId: referenceId,
      idempotencyKey: idempotencyKey,
      reason: reason,
      activityType: activityType,
      metadata: metadata,
      source: source,
    );
  }
}
