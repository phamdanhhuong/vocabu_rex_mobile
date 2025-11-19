import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/entities.dart';
import '../../domain/usecases/usecases.dart';

// Events
abstract class PronunciationEvent {}

class LoadPronunciationProgress extends PronunciationEvent {}

class RefreshPronunciationProgress extends PronunciationEvent {}

// States
abstract class PronunciationState {}

class PronunciationInitial extends PronunciationState {}

class PronunciationLoading extends PronunciationState {}

class PronunciationLoaded extends PronunciationState {
  final PronunciationProgress progress;

  PronunciationLoaded(this.progress);
}

class PronunciationError extends PronunciationState {
  final String message;

  PronunciationError(this.message);
}

// BLoC
class PronunciationBloc extends Bloc<PronunciationEvent, PronunciationState> {
  final GetPronunciationProgressUseCase getPronunciationProgressUseCase;

  PronunciationBloc({required this.getPronunciationProgressUseCase})
    : super(PronunciationInitial()) {
    on<LoadPronunciationProgress>(_onLoadPronunciationProgress);
    on<RefreshPronunciationProgress>(_onRefreshPronunciationProgress);
  }

  Future<void> _onLoadPronunciationProgress(
    LoadPronunciationProgress event,
    Emitter<PronunciationState> emit,
  ) async {
    emit(PronunciationLoading());
    try {
      final progress = await getPronunciationProgressUseCase();
      if (progress != null) {
        emit(PronunciationLoaded(progress));
      } else {
        emit(PronunciationError('No progress data available'));
      }
    } catch (e) {
      emit(PronunciationError('Failed to load pronunciation progress: $e'));
    }
  }

  Future<void> _onRefreshPronunciationProgress(
    RefreshPronunciationProgress event,
    Emitter<PronunciationState> emit,
  ) async {
    try {
      final progress = await getPronunciationProgressUseCase();
      if (progress != null) {
        emit(PronunciationLoaded(progress));
      } else {
        emit(PronunciationError('No progress data available'));
      }
    } catch (e) {
      emit(PronunciationError('Failed to refresh pronunciation progress: $e'));
    }
  }
}
