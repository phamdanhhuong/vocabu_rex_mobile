class UserTierEntity {
  final String currentTier;
  final int consecutiveWeeks;
  final int totalPromotions;
  final int totalDemotions;
  final String highestTier;

  UserTierEntity({
    required this.currentTier,
    required this.consecutiveWeeks,
    required this.totalPromotions,
    required this.totalDemotions,
    required this.highestTier,
  });

  factory UserTierEntity.fromJson(Map<String, dynamic> json) {
    return UserTierEntity(
      currentTier: json['currentTier'] as String,
      consecutiveWeeks: json['consecutiveWeeks'] as int,
      totalPromotions: json['totalPromotions'] as int,
      totalDemotions: json['totalDemotions'] as int,
      highestTier: json['highestTier'] as String,
    );
  }
}
