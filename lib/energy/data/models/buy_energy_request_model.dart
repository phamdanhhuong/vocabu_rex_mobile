class BuyEnergyRequestModel {
  final int energyAmount;
  final String paymentMethod; // 'GEMS' or 'COINS'

  BuyEnergyRequestModel({
    required this.energyAmount,
    required this.paymentMethod,
  });

  Map<String, dynamic> toJson() {
    return {
      'energyAmount': energyAmount,
      'paymentMethod': paymentMethod,
    };
  }
}
