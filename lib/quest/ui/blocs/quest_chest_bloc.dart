import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/quest/domain/usecases/get_unlocked_chests_usecase.dart';
import 'package:vocabu_rex_mobile/quest/domain/usecases/open_chest_usecase.dart';
import 'quest_chest_event.dart';
import 'quest_chest_state.dart';

class QuestChestBloc extends Bloc<QuestChestEvent, QuestChestState> {
  final GetUnlockedChestsUseCase getUnlockedChestsUseCase;
  final OpenChestUseCase openChestUseCase;

  QuestChestBloc({
    required this.getUnlockedChestsUseCase,
    required this.openChestUseCase,
  }) : super(QuestChestInitial()) {
    on<GetUnlockedChestsEvent>(_onGetUnlockedChests);
    on<OpenChestEvent>(_onOpenChest);
    on<RefreshChestsEvent>(_onRefreshChests);
  }

  Future<void> _onGetUnlockedChests(
      GetUnlockedChestsEvent event, Emitter<QuestChestState> emit) async {
    emit(QuestChestLoading());
    try {
      final chests = await getUnlockedChestsUseCase();
      emit(QuestChestLoaded(chests: chests));
    } catch (e) {
      emit(QuestChestError(e.toString()));
    }
  }

  Future<void> _onOpenChest(
      OpenChestEvent event, Emitter<QuestChestState> emit) async {
    if (state is QuestChestLoaded) {
      final currentState = state as QuestChestLoaded;
      emit(QuestChestOpening(
        chests: currentState.chests,
        openingChestId: event.chestId,
      ));

      try {
        final openedChest = await openChestUseCase(event.chestId);
        emit(QuestChestOpened(openedChest: openedChest));

        // Refresh the chest list after opening
        final chests = await getUnlockedChestsUseCase();
        emit(QuestChestLoaded(chests: chests));
      } catch (e) {
        emit(QuestChestError(e.toString()));
        // Restore previous state on error
        emit(currentState);
      }
    }
  }

  Future<void> _onRefreshChests(
      RefreshChestsEvent event, Emitter<QuestChestState> emit) async {
    try {
      final chests = await getUnlockedChestsUseCase();
      emit(QuestChestLoaded(chests: chests));
    } catch (e) {
      emit(QuestChestError(e.toString()));
    }
  }
}
