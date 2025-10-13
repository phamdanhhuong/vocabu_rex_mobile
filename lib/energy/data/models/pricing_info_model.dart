class PricingInfoModel {
  final int gemCost;
  final int coinCost;

  PricingInfoModel({
    required this.gemCost,
    required this.coinCost,
  });

  factory PricingInfoModel.fromJson(Map<String, dynamic> json) {
    return PricingInfoModel(
      gemCost: json['gemCost'] as int,
      coinCost: json['coinCost'] as int,
    );
  }
}
