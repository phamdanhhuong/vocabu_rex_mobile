import 'recharge_info_model.dart';
import 'usage_info_model.dart';
import 'pricing_info_model.dart';
import 'energy_transaction_model.dart';

class GetEnergyStatusResponseModel {
  final String userId;
  final int currentEnergy;
  final int maxEnergy;
  final int energyPercentage;
  final RechargeInfoModel rechargeInfo;
  final UsageInfoModel usage;
  final PricingInfoModel pricing;
  final bool success;
  final List<EnergyTransactionModel> transactions;
  final String? error;

  GetEnergyStatusResponseModel({
    required this.userId,
    required this.currentEnergy,
    required this.maxEnergy,
    required this.energyPercentage,
    required this.rechargeInfo,
    required this.usage,
    required this.pricing,
    required this.success,
    required this.transactions,
    this.error,
  });

  factory GetEnergyStatusResponseModel.fromJson(Map<String, dynamic> json) {
    return GetEnergyStatusResponseModel(
      userId: json['userId'] as String,
      currentEnergy: json['currentEnergy'] as int,
      maxEnergy: json['maxEnergy'] as int,
      energyPercentage: json['energyPercentage'] as int,
      rechargeInfo: RechargeInfoModel.fromJson(json['rechargeInfo']),
      usage: UsageInfoModel.fromJson(json['usage']),
      pricing: PricingInfoModel.fromJson(json['pricing']),
      success: json['success'] as bool,
      transactions: (json['transactions'] as List<dynamic>?)?.map((e) => EnergyTransactionModel.fromJson(e)).toList() ?? [],
      error: json['error'] as String?,
    );
  }
}
