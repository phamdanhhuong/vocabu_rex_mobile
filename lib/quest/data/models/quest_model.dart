class QuestModel {
  final String id;
  final String key;
  final String type;
  final String category;
  final String name;
  final String description;
  final String? iconUrl;
  final int baseRequirement;
  final int rewardXp;
  final int rewardGems;
  final String? chestType;
  final String? badgeIconUrl;
  final bool requiresMultiplayer;
  final int order;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  QuestModel({
    required this.id,
    required this.key,
    required this.type,
    required this.category,
    required this.name,
    required this.description,
    this.iconUrl,
    required this.baseRequirement,
    required this.rewardXp,
    required this.rewardGems,
    this.chestType,
    this.badgeIconUrl,
    required this.requiresMultiplayer,
    required this.order,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QuestModel.fromJson(Map<String, dynamic> json) {
    return QuestModel(
      id: json['id'] as String,
      key: json['key'] as String,
      type: json['type'] as String,
      category: json['category'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconUrl: json['iconUrl'] as String?,
      baseRequirement: json['baseRequirement'] as int,
      rewardXp: json['rewardXp'] as int,
      rewardGems: json['rewardGems'] as int,
      chestType: json['chestType'] as String?,
      badgeIconUrl: json['badgeIconUrl'] as String?,
      requiresMultiplayer: json['requiresMultiplayer'] as bool? ?? false,
      order: json['order'] as int,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'type': type,
      'category': category,
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'baseRequirement': baseRequirement,
      'rewardXp': rewardXp,
      'rewardGems': rewardGems,
      'chestType': chestType,
      'badgeIconUrl': badgeIconUrl,
      'requiresMultiplayer': requiresMultiplayer,
      'order': order,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
