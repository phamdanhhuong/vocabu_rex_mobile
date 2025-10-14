class RechargeInfoEntity {
  final DateTime lastRechargeAt;
  final DateTime nextRechargeAt;
  final int rechargeRate;
  final String timeUntilNextRecharge;
  final int energyToRecharge;

  RechargeInfoEntity({
    required this.lastRechargeAt,
    required this.nextRechargeAt,
    required this.rechargeRate,
    required this.timeUntilNextRecharge,
    required this.energyToRecharge,
  });
}
