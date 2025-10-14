import 'package:vocabu_rex_mobile/energy/domain/entities/pricing_info.dart';
import 'package:vocabu_rex_mobile/energy/domain/entities/recharge_info.dart';
import 'package:vocabu_rex_mobile/energy/domain/entities/usage_info.dart';
import 'package:vocabu_rex_mobile/energy/domain/repositories/energy_repository.dart';

import '../datasources/energy_datasource.dart';
import 'package:vocabu_rex_mobile/energy/domain/entities/energy_entity.dart';
import 'package:vocabu_rex_mobile/energy/domain/entities/energy_transaction_entity.dart';

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
}
