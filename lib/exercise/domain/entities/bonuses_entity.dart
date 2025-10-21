class BonusesEntity {
  final int baseXP;
  final int bonusXP;
  final int perfectBonusXP;

  BonusesEntity({required this.baseXP, required this.bonusXP, required this.perfectBonusXP});

  factory BonusesEntity.fromJson(Map<String, dynamic> json) {
    return BonusesEntity(
      baseXP: (json['baseXP'] ?? 0) as int,
      bonusXP: (json['bonusXP'] ?? 0) as int,
      perfectBonusXP: (json['perfectBonusXP'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'baseXP': baseXP,
      'bonusXP': bonusXP,
      'perfectBonusXP': perfectBonusXP,
    };
  }
}
