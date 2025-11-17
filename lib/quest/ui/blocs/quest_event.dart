// Events
abstract class QuestEvent {}

class GetUserQuestsEvent extends QuestEvent {
  final bool activeOnly;
  GetUserQuestsEvent({this.activeOnly = false});
}

class GetCompletedQuestsEvent extends QuestEvent {}

class ClaimQuestEvent extends QuestEvent {
  final String questId;
  ClaimQuestEvent(this.questId);
}

class RefreshQuestsEvent extends QuestEvent {}
