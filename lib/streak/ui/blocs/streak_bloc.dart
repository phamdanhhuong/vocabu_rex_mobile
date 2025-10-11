import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/streak/domain/entities/get_streak_history_response_entity.dart';
import 'package:vocabu_rex_mobile/streak/domain/usecases/get_streak_history_usecase.dart';

// Events
abstract class StreakEvent {}
class GetStreakHistoryEvent extends StreakEvent {
  final int? limit;
  final bool? includeCurrentStreak;
  GetStreakHistoryEvent({this.limit, this.includeCurrentStreak});
}

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

  StreakBloc({required this.getStreakHistoryUseCase}) : super(StreakInitial()) {
    on<GetStreakHistoryEvent>(_onGetStreakHistory);
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
}
