// Events
abstract class FriendsQuestEvent {}

class GetFriendsQuestParticipantsEvent extends FriendsQuestEvent {
  final String questKey;
  final DateTime weekStartDate;

  GetFriendsQuestParticipantsEvent({
    required this.questKey,
    required this.weekStartDate,
  });
}

class InviteFriendToQuestEvent extends FriendsQuestEvent {
  final String questKey;
  final String friendId;
  final DateTime weekStartDate;

  InviteFriendToQuestEvent({
    required this.questKey,
    required this.friendId,
    required this.weekStartDate,
  });
}

class JoinFriendsQuestEvent extends FriendsQuestEvent {
  final String questKey;
  final DateTime weekStartDate;
  final bool isCreator;

  JoinFriendsQuestEvent({
    required this.questKey,
    required this.weekStartDate,
    this.isCreator = false,
  });
}

class AcceptFriendsQuestInviteEvent extends FriendsQuestEvent {
  final String questKey;
  final DateTime weekStartDate;

  AcceptFriendsQuestInviteEvent({
    required this.questKey,
    required this.weekStartDate,
  });
}

class RejectFriendsQuestInviteEvent extends FriendsQuestEvent {
  final String questKey;
  final DateTime weekStartDate;

  RejectFriendsQuestInviteEvent({
    required this.questKey,
    required this.weekStartDate,
  });
}

