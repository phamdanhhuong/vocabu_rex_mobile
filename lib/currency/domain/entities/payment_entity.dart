class PaymentPackageEntity {
  final String id;
  final String name;
  final int price;
  final int gems;
  final int coins;

  PaymentPackageEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.gems,
    required this.coins,
  });
}

class CreatePaymentResultEntity {
  final String paymentUrl;
  final String orderId;
  final String orderCode;
  final int amount;
  final String packageName;

  CreatePaymentResultEntity({
    required this.paymentUrl,
    required this.orderId,
    required this.orderCode,
    required this.amount,
    required this.packageName,
  });
}
