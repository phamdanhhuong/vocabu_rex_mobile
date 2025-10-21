import 'package:vocabu_rex_mobile/energy/domain/entities/pricing_info.dart';
import 'package:vocabu_rex_mobile/energy/domain/entities/recharge_info.dart';
import 'package:vocabu_rex_mobile/energy/domain/entities/usage_info.dart';
import 'package:vocabu_rex_mobile/energy/domain/entities/buy_energy_entity.dart';
import '../models/consume_energy_response_model.dart';
import 'package:vocabu_rex_mobile/energy/domain/repositories/energy_repository.dart';

import '../datasources/energy_datasource.dart';
import 'package:vocabu_rex_mobile/energy/domain/entities/energy_entity.dart';
import 'package:vocabu_rex_mobile/energy/domain/entities/energy_transaction_entity.dart';
import '../models/buy_energy_request_model.dart';

class EnergyRepositoryImpl implements EnergyRepository{
  final EnergyDatasource datasource;

  EnergyRepositoryImpl({required this.datasource});

  @override
  Future<EnergyEntity> getEnergyStatus({
    bool? includeTransactionHistory,
    int? historyLimit,
  }) async {
    // Giả sử userId lấy từ nơi khác hoặc truyền vào nếu cần
    final model = await datasource.getEnergyStatus(); // Truyền userId nếu cần
    return EnergyEntity(
      userId: model.userId,
      currentEnergy: model.currentEnergy,
      maxEnergy: model.maxEnergy,
      energyPercentage: model.energyPercentage,
      rechargeInfo: RechargeInfoEntity(
        lastRechargeAt: model.rechargeInfo.lastRechargeAt,
        nextRechargeAt: model.rechargeInfo.nextRechargeAt,
        rechargeRate: model.rechargeInfo.rechargeRate,
        timeUntilNextRecharge: model.rechargeInfo.timeUntilNextRecharge,
        energyToRecharge: model.rechargeInfo.energyToRecharge,
      ),
      usage: UsageInfoEntity(
        lastUsedAt: model.usage.lastUsedAt,
        timeSinceLastUse: model.usage.timeSinceLastUse,
      ),
      pricing: PricingInfoEntity(
        gemCost: model.pricing.gemCost,
        coinCost: model.pricing.coinCost,
      ),
      success: model.success,
      transactions: (includeTransactionHistory == true)
          ? (model.transactions)
              .take(historyLimit ?? model.transactions.length)
              .map((e) => EnergyTransactionEntity(
                    id: e.id,
                    energyChange: e.energyChange,
                    reason: e.reason,
                    createdAt: e.createdAt,
                    metadata: e.metadata,
                  ))
              .toList()
          : [],
    );
  }

  @override
  Future<BuyEnergyEntity> buyEnergy({
    required int energyAmount,
    required String paymentMethod,
  }) async {
    final request = BuyEnergyRequestModel(
      energyAmount: energyAmount,
      paymentMethod: paymentMethod,
    );
    final model = await datasource.buyEnergy(request);
    return BuyEnergyEntity(
      userId: model.userId,
      energyPurchased: model.energyPurchased,
      energyBefore: model.energyBefore,
      energyAfter: model.energyAfter,
      costPaid: model.costPaid,
      remainingCurrency: model.remainingCurrency,
      transactionId: model.transactionId,
      success: model.success,
      error: model.error,
    );
  }

  @override
  Future<ConsumeEnergyResponseModel> consumeEnergy({int amount = 1, String? referenceId, String? idempotencyKey, String? reason, String? activityType, Map<String, dynamic>? metadata, String? source}) async {
    final model = await datasource.consumeEnergy(amount: amount, referenceId: referenceId, idempotencyKey: idempotencyKey, reason: reason, activityType: activityType, metadata: metadata, source: source);
    return model;
  }
}
