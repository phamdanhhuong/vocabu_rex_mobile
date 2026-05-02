import 'package:vocabu_rex_mobile/quest/domain/entities/friends_quest_participant_entity.dart';

// States
abstract class FriendsQuestState {}

class FriendsQuestInitial extends FriendsQuestState {}

class FriendsQuestLoading extends FriendsQuestState {}

class FriendsQuestParticipantsLoaded extends FriendsQuestState {
  final List<FriendsQuestParticipantEntity> participants;
  final bool isCurrentUserJoined;

  FriendsQuestParticipantsLoaded(
    this.participants, {
    this.isCurrentUserJoined = false,
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
