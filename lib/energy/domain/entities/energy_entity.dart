import 'energy_transaction_entity.dart';
import 'recharge_info.dart';
import 'usage_info.dart';
import 'pricing_info.dart';

class EnergyEntity {
  final String userId;
  final int currentEnergy;
  final int maxEnergy;
  final int energyPercentage;
  final RechargeInfoEntity rechargeInfo;
  final UsageInfoEntity usage;
  final PricingInfoEntity pricing;
  final bool success;
  final List<EnergyTransactionEntity> transactions;

  EnergyEntity({
    required this.userId,
    required this.currentEnergy,
    required this.maxEnergy,
    required this.energyPercentage,
    required this.rechargeInfo,
    required this.usage,
    required this.pricing,
    required this.success,
    required this.transactions,
  });
}
