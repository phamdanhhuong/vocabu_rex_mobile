import 'package:vocabu_rex_mobile/quest/domain/entities/friends_quest_participant_entity.dart';

// States
abstract class FriendsQuestState {}

class FriendsQuestInitial extends FriendsQuestState {}

class FriendsQuestLoading extends FriendsQuestState {}

class FriendsQuestParticipantsLoaded extends FriendsQuestState {
  final List<FriendsQuestParticipantEntity> participants;
  final bool isCurrentUserJoined;
  final bool isCurrentUserInvited;

  FriendsQuestParticipantsLoaded(
    this.participants, {
    this.isCurrentUserJoined = false,
    this.isCurrentUserInvited = false,
  });
}

class FriendsQuestInviting extends FriendsQuestState {}

class FriendsQuestInvited extends FriendsQuestState {
  final FriendsQuestParticipantEntity participant;

  FriendsQuestInvited(this.participant);
}

class FriendsQuestJoining extends FriendsQuestState {}

class FriendsQuestJoined extends FriendsQuestState {
  final FriendsQuestParticipantEntity participant;

  FriendsQuestJoined(this.participant);
}

class FriendsQuestError extends FriendsQuestState {
  final String message;

  FriendsQuestError(this.message);
}

class FriendsQuestAccepting extends FriendsQuestState {}

class FriendsQuestAccepted extends FriendsQuestState {
  final Map<String, dynamic> response;
  FriendsQuestAccepted(this.response);
}

class FriendsQuestRejecting extends FriendsQuestState {}

class FriendsQuestRejected extends FriendsQuestState {}

