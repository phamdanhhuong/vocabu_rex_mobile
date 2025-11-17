import 'package:vocabu_rex_mobile/quest/data/models/quest_chest_model.dart';
import 'package:vocabu_rex_mobile/quest/domain/enums/quest_enums.dart';

class QuestChestEntity {
  final String id;
  final String userQuestId;
  final ChestType chestType;
  final ChestStatus status;
  final int? rewardXp;
  final int? rewardGems;
  final int? rewardCoins;
  final DateTime? unlockedAt;
  final DateTime? openedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  QuestChestEntity({
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

  factory QuestChestEntity.fromModel(QuestChestModel model) {
    return QuestChestEntity(
      id: model.id,
      userQuestId: model.userQuestId,
      chestType: ChestType.values.firstWhere(
        (e) => e.value == model.chestType,
        orElse: () => ChestType.bronze,
      ),
      status: ChestStatus.values.firstWhere(
        (e) => e.value == model.status,
        orElse: () => ChestStatus.locked,
      ),
      rewardXp: model.rewardXp,
      rewardGems: model.rewardGems,
      rewardCoins: model.rewardCoins,
      unlockedAt: model.unlockedAt,
      openedAt: model.openedAt,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  bool get isLocked => status == ChestStatus.locked;
  bool get isUnlocked => status == ChestStatus.unlocked;
  bool get isOpened => status == ChestStatus.opened;
  bool get canOpen => isUnlocked;
}
