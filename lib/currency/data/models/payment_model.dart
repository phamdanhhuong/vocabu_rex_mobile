class PaymentPackageModel {
  final String id;
  final String name;
  final int price;
  final int gems;
  final int coins;

  PaymentPackageModel({
    required this.id,
    required this.name,
    required this.price,
    required this.gems,
    required this.coins,
  });

  factory PaymentPackageModel.fromJson(Map<String, dynamic> json) {
    return PaymentPackageModel(
      id: json['id'] as String,
      name: json['name'] as String,
      price: json['price'] as int,
      gems: json['gems'] as int,
      coins: json['coins'] as int,
    );
  }
}

class CreatePaymentResultModel {
  final String paymentUrl;
  final String orderId;
  final String orderCode;
  final int amount;
  final String packageName;

  CreatePaymentResultModel({
    required this.paymentUrl,
    required this.orderId,
    required this.orderCode,
    required this.amount,
    required this.packageName,
  });

  factory CreatePaymentResultModel.fromJson(Map<String, dynamic> json) {
    return CreatePaymentResultModel(
      paymentUrl: json['paymentUrl'] as String,
      orderId: json['orderId'] as String,
      orderCode: json['orderCode'] as String,
      amount: json['amount'] as int,
      packageName: json['packageName'] as String,
    );
  }
}
