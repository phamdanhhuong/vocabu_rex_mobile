import 'package:vocabu_rex_mobile/quest/data/models/quest_model.dart';
import 'package:vocabu_rex_mobile/quest/domain/enums/quest_enums.dart';

class QuestEntity {
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
  final ChestType? chestType;
  final String? badgeIconUrl;
  final bool requiresMultiplayer;
  final int order;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  QuestEntity({
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

  factory QuestEntity.fromModel(QuestModel model) {
    return QuestEntity(
      id: model.id,
      key: model.key,
      type: model.type,
      category: model.category,
      name: model.name,
      description: model.description,
      iconUrl: model.iconUrl,
      baseRequirement: model.baseRequirement,
      rewardXp: model.rewardXp,
      rewardGems: model.rewardGems,
      chestType: model.chestType != null
          ? ChestType.values.firstWhere(
              (e) => e.value == model.chestType,
              orElse: () => ChestType.bronze,
            )
          : null,
      badgeIconUrl: model.badgeIconUrl,
      requiresMultiplayer: model.requiresMultiplayer,
      order: model.order,
      isActive: model.isActive,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }
}
