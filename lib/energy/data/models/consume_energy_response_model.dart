class ConsumeEnergyResponseModel {
  final String userId;
  final int energyConsumed; // number of energy points consumed by this request
  final int remainingEnergy; // same as TypeScript `remainingEnergy`
  final int maxEnergy;
  final DateTime? nextRechargeAt;
  final int rechargeRate;
  final bool success;
  final String? error;
  // optional compatibility fields
  final String? transactionId;
  final int? energyBefore;
  final int? energyAfter;

  ConsumeEnergyResponseModel({
    required this.userId,
    required this.energyConsumed,
    required this.remainingEnergy,
    required this.maxEnergy,
    this.nextRechargeAt,
    required this.rechargeRate,
    required this.success,
    this.error,
    this.transactionId,
    this.energyBefore,
    this.energyAfter,
  });

  factory ConsumeEnergyResponseModel.fromJson(Map<String, dynamic> json) {
    // Parse ISO date strings into DateTime if provided
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      if (v is String) return DateTime.tryParse(v);
      return null;
    }

    // Primary shape (match TypeScript ConsumeEnergyResponse)
    final userId = json['userId'] ?? '';
    final energyConsumed = (json['energyConsumed'] ?? 0) as int;
    final remainingEnergy = (json['remainingEnergy'] ?? json['currentEnergy'] ?? json['energyAfter'] ?? 0) as int;
    final maxEnergy = (json['maxEnergy'] ?? 0) as int;
    final nextRechargeAt = parseDate(json['nextRechargeAt']);
    final rechargeRate = (json['rechargeRate'] ?? 0) as int;
    final success = (json['success'] ?? false) as bool;
    final error = json['error'] as String?;

    // Compatibility: transactionId / energyBefore/energyAfter may exist
    final transactionId = json['transactionId'] as String?;
    final energyBefore = (json['energyBefore'] as int?);
    final energyAfter = (json['energyAfter'] as int?);

    return ConsumeEnergyResponseModel(
      userId: userId,
      energyConsumed: energyConsumed,
      remainingEnergy: remainingEnergy,
      maxEnergy: maxEnergy,
      nextRechargeAt: nextRechargeAt,
      rechargeRate: rechargeRate,
      success: success,
      error: error,
      transactionId: transactionId,
      energyBefore: energyBefore,
      energyAfter: energyAfter,
    );
  }
}
