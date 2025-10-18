class BuyEnergyResponseModel {
  final String userId;
  final int energyPurchased;
  final int energyBefore;
  final int energyAfter;
  final Map<String, dynamic> costPaid;
  final Map<String, dynamic> remainingCurrency;
  final String transactionId;
  final bool success;
  final String? error;

  BuyEnergyResponseModel({
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

  factory BuyEnergyResponseModel.fromJson(Map<String, dynamic> json) {
    return BuyEnergyResponseModel(
      userId: json['userId'] ?? '',
      energyPurchased: json['energyPurchased'] ?? 0,
      energyBefore: json['energyBefore'] ?? 0,
      energyAfter: json['energyAfter'] ?? 0,
      costPaid: json['costPaid'] ?? {},
      remainingCurrency: json['remainingCurrency'] ?? {},
      transactionId: json['transactionId'] ?? '',
      success: json['success'] ?? false,
      error: json['error'],
    );
  }
}
