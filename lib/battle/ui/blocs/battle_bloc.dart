import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/battle/data/services/battle_api_service.dart';
import 'package:vocabu_rex_mobile/battle/data/services/battle_socket_service.dart';
import 'package:vocabu_rex_mobile/battle/domain/entities/battle_entities.dart';

// ─── Events ───

abstract class BattleEvent {}

class BattleLoadStats extends BattleEvent {}
class BattleLoadHistory extends BattleEvent {}
class BattleFindMatch extends BattleEvent {}
class BattleCancelSearch extends BattleEvent {}
class BattleSubmitAnswer extends BattleEvent {
  final String answer;
  final int timeMs;
  BattleSubmitAnswer({required this.answer, required this.timeMs});
}
class BattleReset extends BattleEvent {}

// Internal events from socket
class _BattleSearching extends BattleEvent {
  final Map<String, dynamic> data;
  _BattleSearching(this.data);
}
class _BattleMatchFound extends BattleEvent {
  final Map<String, dynamic> data;
  _BattleMatchFound(this.data);
}
class _BattleRoundStart extends BattleEvent {
  final Map<String, dynamic> data;
  _BattleRoundStart(this.data);
}
class _BattleOpponentAnswered extends BattleEvent {}
class _BattleRoundResult extends BattleEvent {
  final Map<String, dynamic> data;
  _BattleRoundResult(this.data);
}
class _BattleMatchResult extends BattleEvent {
  final Map<String, dynamic> data;
  _BattleMatchResult(this.data);
}

// ─── States ───

abstract class BattleState {}

class BattleInitial extends BattleState {}

class BattleStatsLoaded extends BattleState {
  final BattleStatsEntity stats;
  final List<BattleHistoryEntity> history;
  BattleStatsLoaded({required this.stats, required this.history});
}

class BattleSearching extends BattleState {
  final String? tier;
  BattleSearching({this.tier});
}

class BattleMatchReady extends BattleState {
  final BattleMatchEntity match;
  BattleMatchReady({required this.match});
}

class BattleRoundActive extends BattleState {
  final BattleMatchEntity match;
  final BattleQuestionEntity question;
  final int player1Score;
  final int player2Score;
  final bool opponentAnswered;
  final bool myAnswerSubmitted;

  BattleRoundActive({
    required this.match,
    required this.question,
    this.player1Score = 0,
    this.player2Score = 0,
    this.opponentAnswered = false,
    this.myAnswerSubmitted = false,
  });

  BattleRoundActive copyWith({
    bool? opponentAnswered,
    bool? myAnswerSubmitted,
    int? player1Score,
    int? player2Score,
  }) {
    return BattleRoundActive(
      match: match,
      question: question,
      player1Score: player1Score ?? this.player1Score,
      player2Score: player2Score ?? this.player2Score,
      opponentAnswered: opponentAnswered ?? this.opponentAnswered,
      myAnswerSubmitted: myAnswerSubmitted ?? this.myAnswerSubmitted,
    );
  }
}

class BattleRoundResultState extends BattleState {
  final BattleMatchEntity match;
  final BattleRoundResultEntity result;
  final String? myAnswer;
  BattleRoundResultState({required this.match, required this.result, this.myAnswer});
}

class BattleMatchResultState extends BattleState {
  final BattleResultEntity result;
  final String myUserId;

  String get outcome {
    if (result.winnerId == null) return 'DRAW';
    return result.winnerId == myUserId ? 'WIN' : 'LOSE';
  }

  BattleMatchResultState({required this.result, required this.myUserId});
}

class BattleError extends BattleState {
  final String message;
  BattleError(this.message);
}

// ─── BLoC ───

class BattleBloc extends Bloc<BattleEvent, BattleState> {
  final BattleApiService apiService;
  final BattleSocketService socketService;

  BattleMatchEntity? _currentMatch;
  String? _myUserId;
  String? _lastAnswer;
  List<StreamSubscription>? _subs;

  BattleBloc({
    required this.apiService,
    required this.socketService,
  }) : super(BattleInitial()) {
    on<BattleLoadStats>(_onLoadStats);
    on<BattleLoadHistory>(_onLoadHistory);
    on<BattleFindMatch>(_onFindMatch);
    on<BattleCancelSearch>(_onCancelSearch);
    on<BattleSubmitAnswer>(_onSubmitAnswer);
    on<BattleReset>(_onReset);
    on<_BattleSearching>(_onSearching);
    on<_BattleMatchFound>(_onMatchFound);
    on<_BattleRoundStart>(_onRoundStart);
    on<_BattleOpponentAnswered>(_onOpponentAnswered);
    on<_BattleRoundResult>(_onRoundResult);
    on<_BattleMatchResult>(_onMatchResult);
  }

  void setUserId(String userId) => _myUserId = userId;

  Future<void> _onLoadStats(BattleLoadStats event, Emitter<BattleState> emit) async {
    try {
      final statsData = await apiService.getStats();
      final historyData = await apiService.getHistory(limit: 5);

      final stats = BattleStatsEntity.fromJson(statsData);
      final historyList = historyData
          .map((e) => BattleHistoryEntity.fromJson(e as Map<String, dynamic>))
          .toList();

      emit(BattleStatsLoaded(stats: stats, history: historyList));
    } catch (e) {
      emit(BattleStatsLoaded(
        stats: BattleStatsEntity(totalMatches: 0, wins: 0, losses: 0, draws: 0, winStreak: 0, bestWinStreak: 0),
        history: [],
      ));
    }
  }

  Future<void> _onLoadHistory(BattleLoadHistory event, Emitter<BattleState> emit) async {
    // Handled in loadStats
  }

  Future<void> _onFindMatch(BattleFindMatch event, Emitter<BattleState> emit) async {
    try {
      if (!socketService.isConnected) {
        await socketService.connect();
        await Future.delayed(const Duration(milliseconds: 500));
      }

      _listenToSocket();
      socketService.findMatch();
      emit(BattleSearching());
    } catch (e) {
      emit(BattleError('Không thể kết nối server'));
    }
  }

  void _onCancelSearch(BattleCancelSearch event, Emitter<BattleState> emit) {
    socketService.cancelSearch();
    _cancelSubs();
    emit(BattleInitial());
    add(BattleLoadStats());
  }

  void _onSubmitAnswer(BattleSubmitAnswer event, Emitter<BattleState> emit) {
    if (_currentMatch == null) return;
    final current = state;
    if (current is! BattleRoundActive) return;

    _lastAnswer = event.answer;
    socketService.submitAnswer(
      matchId: _currentMatch!.matchId,
      roundNumber: current.question.roundNumber,
      answer: event.answer,
      timeMs: event.timeMs,
    );
    emit(current.copyWith(myAnswerSubmitted: true));
  }

  void _onReset(BattleReset event, Emitter<BattleState> emit) {
    _cancelSubs();
    _currentMatch = null;
    emit(BattleInitial());
    add(BattleLoadStats());
  }

  // ─── Socket event handlers ───

  void _onSearching(_BattleSearching event, Emitter<BattleState> emit) {
    emit(BattleSearching(tier: event.data['tier']));
  }

  void _onMatchFound(_BattleMatchFound event, Emitter<BattleState> emit) {
    _currentMatch = BattleMatchEntity.fromJson(event.data);
    emit(BattleMatchReady(match: _currentMatch!));

    // Auto-transition to first round after countdown
    Future.delayed(const Duration(seconds: 3), () {
      if (_currentMatch?.firstRound != null) {
        add(_BattleRoundStart(event.data['firstRound']));
      }
    });
  }

  void _onRoundStart(_BattleRoundStart event, Emitter<BattleState> emit) {
    if (_currentMatch == null) return;
    final question = BattleQuestionEntity.fromJson(event.data);
    final currentState = state;
    int p1Score = 0, p2Score = 0;
    if (currentState is BattleRoundResultState) {
      p1Score = currentState.result.player1TotalScore;
      p2Score = currentState.result.player2TotalScore;
    }
    emit(BattleRoundActive(
      match: _currentMatch!,
      question: question,
      player1Score: p1Score,
      player2Score: p2Score,
    ));
  }

  void _onOpponentAnswered(_BattleOpponentAnswered event, Emitter<BattleState> emit) {
    if (state is BattleRoundActive) {
      emit((state as BattleRoundActive).copyWith(opponentAnswered: true));
    }
  }

  void _onRoundResult(_BattleRoundResult event, Emitter<BattleState> emit) {
    if (_currentMatch == null) return;
    final result = BattleRoundResultEntity.fromJson(event.data);
    emit(BattleRoundResultState(
      match: _currentMatch!,
      result: result,
      myAnswer: _lastAnswer,
    ));
  }

  void _onMatchResult(_BattleMatchResult event, Emitter<BattleState> emit) {
    final result = BattleResultEntity.fromJson(event.data);
    emit(BattleMatchResultState(result: result, myUserId: _myUserId ?? ''));
    _cancelSubs();
  }

  // ─── Socket subscription management ───

  void _listenToSocket() {
    _cancelSubs();
    _subs = [
      socketService.onSearching.listen((d) => add(_BattleSearching(d))),
      socketService.onMatchFound.listen((d) => add(_BattleMatchFound(d))),
      socketService.onRoundStart.listen((d) => add(_BattleRoundStart(d))),
      socketService.onOpponentAnswered.listen((_) => add(_BattleOpponentAnswered())),
      socketService.onRoundResult.listen((d) => add(_BattleRoundResult(d))),
      socketService.onMatchResult.listen((d) => add(_BattleMatchResult(d))),
      socketService.onError.listen((msg) => add(BattleReset())),
    ];
  }

  void _cancelSubs() {
    if (_subs != null) {
      for (final s in _subs!) {
        s.cancel();
      }
      _subs = null;
    }
  }

  @override
  Future<void> close() {
    _cancelSubs();
    socketService.dispose();
    return super.close();
  }
}
