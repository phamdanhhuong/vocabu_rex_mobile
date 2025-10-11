class CurrencyTransactionEntity {
  final String id;
  final String currencyType;
  final int amount;
  final String reason;
  final String? description;
  final DateTime createdAt;

  CurrencyTransactionEntity({
    required this.id,
    required this.currencyType,
    required this.amount,
    required this.reason,
    this.description,
    required this.createdAt,
  });
}
