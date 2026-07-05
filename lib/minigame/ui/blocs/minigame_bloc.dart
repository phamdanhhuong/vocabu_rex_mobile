import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/minigame/domain/entities/minigame_result_entity.dart';
import 'package:vocabu_rex_mobile/minigame/domain/entities/minigame_session_entity.dart';
import 'package:vocabu_rex_mobile/minigame/domain/entities/minigame_status_entity.dart';
import 'package:vocabu_rex_mobile/minigame/domain/usecases/get_minigame_usecase.dart';
import 'package:vocabu_rex_mobile/minigame/domain/usecases/get_minigame_status_usecase.dart';
import 'package:vocabu_rex_mobile/minigame/domain/usecases/submit_minigame_usecase.dart';

// ─── Events ──────────────────────────────────────────────────────────────────

abstract class MiniGameEvent {}

/// Load status kỷ lục 2 game types cho mode picker
class LoadMiniGameStatusEvent extends MiniGameEvent {
  final String partId;
  LoadMiniGameStatusEvent(this.partId);
}

/// Bắt đầu tải session (exercises) để chơi
class LoadMiniGameSessionEvent extends MiniGameEvent {
  final String partId;
  final String gameType;
  LoadMiniGameSessionEvent({required this.partId, required this.gameType});
}

/// User chọn đúng/sai 1 câu trong game
class MiniGameAnswerEvent extends MiniGameEvent {
  final bool isCorrect;
  MiniGameAnswerEvent(this.isCorrect);
}

/// Chuyển sang câu tiếp theo
class MiniGameNextQuestionEvent extends MiniGameEvent {}

/// Submit kết quả sau khi hết câu
class SubmitMiniGameEvent extends MiniGameEvent {
  final String partId;
  final String gameType;
  final int score;
  final int timeSpentMs;
  final int mistakesCount;

  SubmitMiniGameEvent({
    required this.partId,
    required this.gameType,
    required this.score,
    required this.timeSpentMs,
    required this.mistakesCount,
  });
}

/// Reset về trạng thái ban đầu
class ResetMiniGameEvent extends MiniGameEvent {}

// ─── States ──────────────────────────────────────────────────────────────────

abstract class MiniGameState {}

class MiniGameInitial extends MiniGameState {}

class MiniGameStatusLoading extends MiniGameState {}

class MiniGameStatusLoaded extends MiniGameState {
  final List<MiniGameStatusEntity> statuses;
  MiniGameStatusLoaded(this.statuses);

  MiniGameStatusEntity? getStatus(String gameType) {
    try {
      return statuses.firstWhere((s) => s.gameType == gameType);
    } catch (_) {
      return null;
    }
  }
}

class MiniGameLoading extends MiniGameState {}

class MiniGameLoaded extends MiniGameState {
  final MiniGameSessionEntity session;
  final int currentIndex;
  final int score;
  final int mistakesCount;
  final bool? isCorrect; // null = chưa trả lời, true/false = kết quả
  final DateTime startTime;

  MiniGameLoaded({
    required this.session,
    this.currentIndex = 0,
    this.score = 0,
    this.mistakesCount = 0,
    this.isCorrect,
    required this.startTime,
  });

  MiniGameLoaded copyWith({
    MiniGameSessionEntity? session,
    int? currentIndex,
    int? score,
    int? mistakesCount,
    bool? isCorrect,
    bool clearCorrect = false,
  }) {
    return MiniGameLoaded(
      session: session ?? this.session,
      currentIndex: currentIndex ?? this.currentIndex,
      score: score ?? this.score,
      mistakesCount: mistakesCount ?? this.mistakesCount,
      isCorrect: clearCorrect ? null : (isCorrect ?? this.isCorrect),
      startTime: startTime,
    );
  }

  int get timeSpentMs =>
      DateTime.now().difference(startTime).inMilliseconds;

  bool get isFinished =>
      currentIndex >= session.exercises.length;
}

class MiniGameSubmitting extends MiniGameState {}

class MiniGameCompleted extends MiniGameState {
  final MiniGameResultEntity result;
  MiniGameCompleted(this.result);
}

class MiniGameError extends MiniGameState {
  final String message;
  MiniGameError(this.message);
}

// ─── Bloc ─────────────────────────────────────────────────────────────────────

class MiniGameBloc extends Bloc<MiniGameEvent, MiniGameState> {
  final GetMiniGameUseCase getMiniGameUseCase;
  final SubmitMiniGameUseCase submitMiniGameUseCase;
  final GetMiniGameStatusUseCase getMiniGameStatusUseCase;

  MiniGameBloc({
    required this.getMiniGameUseCase,
    required this.submitMiniGameUseCase,
    required this.getMiniGameStatusUseCase,
  }) : super(MiniGameInitial()) {
    on<LoadMiniGameStatusEvent>(_onLoadStatus);
    on<LoadMiniGameSessionEvent>(_onLoadSession);
    on<MiniGameAnswerEvent>(_onAnswer);
    on<MiniGameNextQuestionEvent>(_onNext);
    on<SubmitMiniGameEvent>(_onSubmit);
    on<ResetMiniGameEvent>(_onReset);
  }

  Future<void> _onLoadStatus(
    LoadMiniGameStatusEvent event,
    Emitter<MiniGameState> emit,
  ) async {
    emit(MiniGameStatusLoading());
    try {
      final statuses = await getMiniGameStatusUseCase(event.partId);
      emit(MiniGameStatusLoaded(statuses));
    } catch (e) {
      // Không hiện lỗi khi chỉ load status — trả về list rỗng
      emit(MiniGameStatusLoaded([]));
    }
  }

  Future<void> _onLoadSession(
    LoadMiniGameSessionEvent event,
    Emitter<MiniGameState> emit,
  ) async {
    emit(MiniGameLoading());
    try {
      final session = await getMiniGameUseCase(
        partId: event.partId,
        gameType: event.gameType,
      );
      if (session.exercises.isEmpty) {
        emit(MiniGameError('Không có bài tập cho chế độ này. Hãy thử chế độ khác!'));
        return;
      }
      emit(MiniGameLoaded(session: session, startTime: DateTime.now()));
    } catch (e) {
      emit(MiniGameError(e.toString()));
    }
  }

  void _onAnswer(MiniGameAnswerEvent event, Emitter<MiniGameState> emit) {
    final current = state;
    if (current is MiniGameLoaded) {
      emit(current.copyWith(
        isCorrect: event.isCorrect,
        score: event.isCorrect ? current.score + 10 : current.score,
        mistakesCount:
            event.isCorrect ? current.mistakesCount : current.mistakesCount + 1,
      ));
    }
  }

  void _onNext(MiniGameNextQuestionEvent event, Emitter<MiniGameState> emit) {
    final current = state;
    if (current is MiniGameLoaded) {
      emit(current.copyWith(
        currentIndex: current.currentIndex + 1,
        clearCorrect: true,
      ));
    }
  }

  Future<void> _onSubmit(
    SubmitMiniGameEvent event,
    Emitter<MiniGameState> emit,
  ) async {
    emit(MiniGameSubmitting());
    try {
      final result = await submitMiniGameUseCase(
        partId: event.partId,
        gameType: event.gameType,
        score: event.score,
        timeSpentMs: event.timeSpentMs,
        mistakesCount: event.mistakesCount,
      );
      emit(MiniGameCompleted(result));
    } catch (e) {
      emit(MiniGameError(e.toString()));
    }
  }

  void _onReset(ResetMiniGameEvent event, Emitter<MiniGameState> emit) {
    emit(MiniGameInitial());
  }
}
