import 'package:vocabu_rex_mobile/quest/domain/entities/quest_chest_entity.dart';

// States
abstract class QuestChestState {}

class QuestChestInitial extends QuestChestState {}

class QuestChestLoading extends QuestChestState {}

class QuestChestLoaded extends QuestChestState {
  final List<QuestChestEntity> chests;

  QuestChestLoaded({required this.chests});
}

class QuestChestOpening extends QuestChestState {
  final List<QuestChestEntity> chests;
  final String openingChestId;

  QuestChestOpening({
    required this.chests,
    required this.openingChestId,
  });
}

class QuestChestOpened extends QuestChestState {
  final QuestChestEntity openedChest;

  QuestChestOpened({required this.openedChest});
}

class QuestChestError extends QuestChestState {
  final String message;
  QuestChestError(this.message);
}
