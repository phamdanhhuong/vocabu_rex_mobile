import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/quest/domain/usecases/get_friends_quest_participants_usecase.dart';
import 'package:vocabu_rex_mobile/quest/domain/usecases/invite_friend_to_quest_usecase.dart';
import 'package:vocabu_rex_mobile/quest/domain/usecases/join_friends_quest_usecase.dart';
import 'friends_quest_event.dart';
import 'friends_quest_state.dart';
import 'package:vocabu_rex_mobile/quest/data/services/quest_service.dart';

class FriendsQuestBloc extends Bloc<FriendsQuestEvent, FriendsQuestState> {
  final GetFriendsQuestParticipantsUseCase getFriendsQuestParticipantsUseCase;
  final InviteFriendToQuestUseCase inviteFriendToQuestUseCase;
  final JoinFriendsQuestUseCase joinFriendsQuestUseCase;
  String? currentUserId;

  FriendsQuestBloc({
    required this.getFriendsQuestParticipantsUseCase,
    required this.inviteFriendToQuestUseCase,
    required this.joinFriendsQuestUseCase,
    this.currentUserId,
  }) : super(FriendsQuestInitial()) {
    on<GetFriendsQuestParticipantsEvent>(_onGetParticipants);
    on<InviteFriendToQuestEvent>(_onInviteFriend);
    on<JoinFriendsQuestEvent>(_onJoinQuest);
    on<AcceptFriendsQuestInviteEvent>(_onAcceptInvite);
    on<RejectFriendsQuestInviteEvent>(_onRejectInvite);
  }

  Future<void> _onGetParticipants(
    GetFriendsQuestParticipantsEvent event,
    Emitter<FriendsQuestState> emit,
  ) async {
    emit(FriendsQuestLoading());
    try {
      final participants = await getFriendsQuestParticipantsUseCase(
        event.questKey,
        event.weekStartDate,
      );
      // Check if currentUser is already joined
      final isJoined =
          currentUserId != null &&
          participants.any((p) => p.userId == currentUserId && p.status == 'ACCEPTED');
      final isInvited =
          currentUserId != null &&
          participants.any((p) => p.userId == currentUserId && p.status == 'PENDING');
      emit(
        FriendsQuestParticipantsLoaded(
          participants,
          isCurrentUserJoined: isJoined,
          isCurrentUserInvited: isInvited,
        ),
      );
    } catch (e) {
      emit(FriendsQuestError(e.toString()));
    }
  }

  Future<void> _onInviteFriend(
    InviteFriendToQuestEvent event,
    Emitter<FriendsQuestState> emit,
  ) async {
    emit(FriendsQuestInviting());
    try {
      final participant = await inviteFriendToQuestUseCase(
        event.questKey,
        event.friendId,
        event.weekStartDate,
      );
      emit(FriendsQuestInvited(participant));

      // Reload participants after inviting
      add(
        GetFriendsQuestParticipantsEvent(
          questKey: event.questKey,
          weekStartDate: event.weekStartDate,
        ),
      );
    } catch (e) {
      emit(FriendsQuestError(e.toString()));
    }
  }

  Future<void> _onJoinQuest(
    JoinFriendsQuestEvent event,
    Emitter<FriendsQuestState> emit,
  ) async {
    emit(FriendsQuestJoining());
    try {
      final participant = await joinFriendsQuestUseCase(
        event.questKey,
        event.weekStartDate,
        isCreator: event.isCreator,
      );
      emit(FriendsQuestJoined(participant));

      // Reload participants after joining
      add(
        GetFriendsQuestParticipantsEvent(
          questKey: event.questKey,
          weekStartDate: event.weekStartDate,
        ),
      );
    } catch (e) {
      emit(FriendsQuestError(e.toString()));
    }
  }

  Future<void> _onAcceptInvite(
    AcceptFriendsQuestInviteEvent event,
    Emitter<FriendsQuestState> emit,
  ) async {
    emit(FriendsQuestAccepting());
    try {
      final response = await QuestService().acceptFriendsQuestInvite(event.questKey);
      emit(FriendsQuestAccepted(response));

      // Reload participants after accepting
      add(
        GetFriendsQuestParticipantsEvent(
          questKey: event.questKey,
          weekStartDate: event.weekStartDate,
        ),
      );
    } catch (e) {
      emit(FriendsQuestError(e.toString()));
    }
  }

  Future<void> _onRejectInvite(
    RejectFriendsQuestInviteEvent event,
    Emitter<FriendsQuestState> emit,
  ) async {
    emit(FriendsQuestRejecting());
    try {
      await QuestService().rejectFriendsQuestInvite(event.questKey);
      emit(FriendsQuestRejected());

      // Reload participants after rejecting
      add(
        GetFriendsQuestParticipantsEvent(
          questKey: event.questKey,
          weekStartDate: event.weekStartDate,
        ),
      );
    } catch (e) {
      emit(FriendsQuestError(e.toString()));
    }
  }
}
