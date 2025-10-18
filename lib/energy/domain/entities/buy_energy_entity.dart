class BuyEnergyEntity {
  final String userId;
  final int energyPurchased;
  final int energyBefore;
  final int energyAfter;
  final Map<String, dynamic> costPaid;
  final Map<String, dynamic> remainingCurrency;
  final String transactionId;
  final bool success;
  final String? error;

  BuyEnergyEntity({
    required this.userId,
    required this.energyPurchased,
    required this.energyBefore,
    required this.energyAfter,
    required this.costPaid,
    required this.remainingCurrency,
    required this.transactionId,
    required this.success,
    this.error,
  });
}
