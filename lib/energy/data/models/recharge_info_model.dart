class RechargeInfoModel {
  final DateTime lastRechargeAt;
  final DateTime nextRechargeAt;
  final int rechargeRate;
  final String timeUntilNextRecharge;
  final int energyToRecharge;

  RechargeInfoModel({
    required this.lastRechargeAt,
    required this.nextRechargeAt,
    required this.rechargeRate,
    required this.timeUntilNextRecharge,
    required this.energyToRecharge,
  });

  factory RechargeInfoModel.fromJson(Map<String, dynamic> json) {
    return RechargeInfoModel(
      lastRechargeAt: DateTime.parse(json['lastRechargeAt']),
      nextRechargeAt: DateTime.parse(json['nextRechargeAt']),
      rechargeRate: json['rechargeRate'] as int,
      timeUntilNextRecharge: json['timeUntilNextRecharge'] as String,
      energyToRecharge: json['energyToRecharge'] as int,
    );
  }
}
