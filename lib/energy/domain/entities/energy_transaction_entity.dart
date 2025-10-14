class EnergyTransactionEntity {
  final String id;
  final int energyChange;
  final String reason;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;

  EnergyTransactionEntity({
    required this.id,
    required this.energyChange,
    required this.reason,
    required this.createdAt,
    required this.metadata,
  });
}
