class QuestChestModel {
  final String id;
  final String userQuestId;
  final String chestType;
  final String status;
  final int? rewardXp;
  final int? rewardGems;
  final int? rewardCoins;
  final DateTime? unlockedAt;
  final DateTime? openedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  QuestChestModel({
    required this.id,
    required this.userQuestId,
    required this.chestType,
    required this.status,
    this.rewardXp,
    this.rewardGems,
    this.rewardCoins,
    this.unlockedAt,
    this.openedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QuestChestModel.fromJson(Map<String, dynamic> json) {
    return QuestChestModel(
      id: json['id'] as String,
      userQuestId: json['userQuestId'] as String,
      chestType: json['chestType'] as String,
      status: json['status'] as String,
      rewardXp: json['rewardXp'] as int?,
      rewardGems: json['rewardGems'] as int?,
      rewardCoins: json['rewardCoins'] as int?,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
      openedAt: json['openedAt'] != null
          ? DateTime.parse(json['openedAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userQuestId': userQuestId,
      'chestType': chestType,
      'status': status,
      'rewardXp': rewardXp,
      'rewardGems': rewardGems,
      'rewardCoins': rewardCoins,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'openedAt': openedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
