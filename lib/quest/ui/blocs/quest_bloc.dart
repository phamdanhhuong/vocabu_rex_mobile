import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/quest/domain/entities/user_quest_entity.dart';
import 'package:vocabu_rex_mobile/quest/domain/usecases/claim_quest_usecase.dart';
import 'package:vocabu_rex_mobile/quest/domain/usecases/get_completed_quests_usecase.dart';
import 'package:vocabu_rex_mobile/quest/domain/usecases/get_user_quests_usecase.dart';
import 'quest_event.dart';
import 'quest_state.dart';

class QuestBloc extends Bloc<QuestEvent, QuestState> {
  final GetUserQuestsUseCase getUserQuestsUseCase;
  final GetCompletedQuestsUseCase getCompletedQuestsUseCase;
  final ClaimQuestUseCase claimQuestUseCase;

  QuestBloc({
    required this.getUserQuestsUseCase,
    required this.getCompletedQuestsUseCase,
    required this.claimQuestUseCase,
  }) : super(QuestInitial()) {
    on<GetUserQuestsEvent>(_onGetUserQuests);
    on<GetCompletedQuestsEvent>(_onGetCompletedQuests);
    on<ClaimQuestEvent>(_onClaimQuest);
    on<RefreshQuestsEvent>(_onRefreshQuests);
  }

  Future<void> _onGetUserQuests(
      GetUserQuestsEvent event, Emitter<QuestState> emit) async {
    emit(QuestLoading());
    try {
      final quests = await getUserQuestsUseCase(activeOnly: event.activeOnly);
      _emitLoadedState(quests, emit);
    } catch (e) {
      emit(QuestError(e.toString()));
    }
  }

  Future<void> _onGetCompletedQuests(
      GetCompletedQuestsEvent event, Emitter<QuestState> emit) async {
    emit(QuestLoading());
    try {
      final quests = await getCompletedQuestsUseCase();
      _emitLoadedState(quests, emit);
    } catch (e) {
      emit(QuestError(e.toString()));
    }
  }

  Future<void> _onClaimQuest(
      ClaimQuestEvent event, Emitter<QuestState> emit) async {
    if (state is QuestLoaded) {
      final currentState = state as QuestLoaded;
      emit(QuestClaiming(
          quests: currentState.quests, claimingQuestId: event.questId));

      try {
        final updatedQuest = await claimQuestUseCase(event.questId);
        
        // Update the quest list with the claimed quest
        final updatedQuests = currentState.quests.map((q) {
          return q.id == updatedQuest.id ? updatedQuest : q;
        }).toList();

        _emitLoadedState(updatedQuests, emit);
      } catch (e) {
        emit(QuestError(e.toString()));
        // Restore previous state on error
        emit(currentState);
      }
    }
  }

  Future<void> _onRefreshQuests(
      RefreshQuestsEvent event, Emitter<QuestState> emit) async {
    try {
      final quests = await getUserQuestsUseCase(activeOnly: false);
      _emitLoadedState(quests, emit);
    } catch (e) {
      emit(QuestError(e.toString()));
    }
  }

  void _emitLoadedState(List<UserQuestEntity> quests, Emitter<QuestState> emit) {
    final dailyQuests = quests
        .where((q) => q.quest.type == 'DAILY')
        .toList()
      ..sort((a, b) => a.quest.order.compareTo(b.quest.order));

    final friendsQuests = quests
        .where((q) => q.quest.type == 'FRIENDS')
        .toList()
      ..sort((a, b) => a.quest.order.compareTo(b.quest.order));

    final monthlyBadgeQuests = quests
        .where((q) => q.quest.type == 'MONTHLY_BADGE')
        .toList()
      ..sort((a, b) => a.quest.order.compareTo(b.quest.order));

    final completedToday = dailyQuests.where((q) => q.isCompleted).length;
    final totalDaily = dailyQuests.length;

    emit(QuestLoaded(
      quests: quests,
      dailyQuests: dailyQuests,
      friendsQuests: friendsQuests,
      monthlyBadgeQuests: monthlyBadgeQuests,
      completedToday: completedToday,
      totalDaily: totalDaily,
    ));
  }
}
