import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/streak/domain/entities/get_streak_history_response_entity.dart';
import 'package:vocabu_rex_mobile/streak/domain/usecases/get_streak_history_usecase.dart';
import 'streak_event.dart';
import 'package:vocabu_rex_mobile/streak/domain/usecases/use_streak_freeze_usecase.dart';

// States
abstract class StreakState {}
class StreakInitial extends StreakState {}
class StreakLoading extends StreakState {}
class StreakLoaded extends StreakState {
  final GetStreakHistoryResponseEntity response;
  StreakLoaded(this.response);
}
class StreakError extends StreakState {
  final String message;
  StreakError(this.message);
}

// Bloc
class StreakBloc extends Bloc<StreakEvent, StreakState> {
  final GetStreakHistoryUseCase getStreakHistoryUseCase;
  final UseStreakFreezeUseCase useStreakFreezeUseCase;

  StreakBloc({required this.getStreakHistoryUseCase, required this.useStreakFreezeUseCase}) : super(StreakInitial()) {
    on<GetStreakHistoryEvent>(_onGetStreakHistory);
    on<UseStreakFreezeEvent>(_onUseStreakFreeze);
  }

  Future<void> _onGetStreakHistory(GetStreakHistoryEvent event, Emitter<StreakState> emit) async {
    emit(StreakLoading());
    try {
      final response = await getStreakHistoryUseCase.call(limit: event.limit, includeCurrentStreak: event.includeCurrentStreak);
      emit(StreakLoaded(response));
    } catch (e) {
      emit(StreakError(e.toString()));
    }
  }

  Future<void> _onUseStreakFreeze(UseStreakFreezeEvent event, Emitter<StreakState> emit) async {
    emit(StreakLoading());
    try {
      await useStreakFreezeUseCase.call(reason: event.reason);
      add(GetStreakHistoryEvent());
    } catch (e) {
      emit(StreakError(e.toString()));
    }
  }
}
