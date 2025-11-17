// Events
abstract class QuestChestEvent {}

class GetUnlockedChestsEvent extends QuestChestEvent {}

class OpenChestEvent extends QuestChestEvent {
  final String chestId;
  OpenChestEvent(this.chestId);
}

class RefreshChestsEvent extends QuestChestEvent {}
