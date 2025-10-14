class EnergyTransactionModel {
  final String id;
  final int energyChange;
  final String reason;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;

  EnergyTransactionModel({
    required this.id,
    required this.energyChange,
    required this.reason,
    required this.createdAt,
    required this.metadata,
  });

  factory EnergyTransactionModel.fromJson(Map<String, dynamic> json) {
    return EnergyTransactionModel(
      id: json['id'] as String,
      energyChange: json['energyChange'] as int,
      reason: json['reason'] as String,
      createdAt: DateTime.parse(json['createdAt']),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map),
    );
  }
}
